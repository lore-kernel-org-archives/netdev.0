From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/10] dynamic_debug: make netif_dbg() call
 __netdev_printk()
Date: Thu, 07 Jul 2011 09:29:21 -0700
Message-ID: <1310056161.27526.47.camel@Joe-Laptop>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <1309989543.1710.19.camel@Joe-Laptop>  <20110707141259.GA2536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110707141259.GA2536@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-07-07 at 10:13 -0400, Jason Baron wrote:
> On Wed, Jul 06, 2011 at 02:59:03PM -0700, Joe Perches wrote:
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > > @@ -2731,10 +2731,8 @@ do {								\
> > >  #elif defined(CONFIG_DYNAMIC_DEBUG)
> > >  #define netif_dbg(priv, type, netdev, format, args...)		\
> > >  do {								\
> > > -	if (netif_msg_##type(priv))				\
> > > -		dynamic_dev_dbg((netdev)->dev.parent,		\
> > > -				"%s: " format,			\
> > > -				netdev_name(netdev), ##args);	\
> > > +	dynamic_netif_dbg(netdev, (netif_msg_##type(priv)),	\
> > > +				  format, ##args);		\
> > Because you've already added dynamic_netdev_dbg,
> > maybe this should be:
> > #define netif_dbg(priv, type, netdev, format, args...)		\
> > do {								\
> > 	if (netif_msg_##type(priv))				\
> > 		dynamic_netdev_dbg(netdev, format, ##args);	\
> > } while (0)
> The reason I didn't add it this way is b/c I plan on converting the
> outer 'ifs' to the jump label infrastructure - which makes the disabled
> case just a no-op and moves the printk and tests out of line.

Perhaps you needn't do that.

I think there's little to be gained to move the test
outwards and not perform the netif_msg##type(priv)

> Until that is done, i could see coding it as you've suggested, but I'd
> prefer to leave it as is (and leave future churn to within the dynamic
> debug code as opposed to the netdevice.h header).

Shrug.  I think that dynamic_debug will have continuing
impacts on various subsystems unless there's some generic
__dynamic_dbg() and _prefix() mechanism introduced into
more generic <foo>_dbg style.

Anything logging message that uses <foo>_dbg or <foo>_vdbg
is a candidate for dynamic_debug uses, but there's no
current generic mechanism to avoid subsystem specific needs.

Any of these could need some dynamic_debug consideration:

$ grep -rPoh --include=*.[ch] "[a-z_]+_[v]?dbg\(" * | sort | uniq
acpi_ut_allocate_object_desc_dbg(
acpi_ut_create_internal_object_dbg(
adc_dbg(
add_dyn_dbg(
airo_print_dbg(
ata_dev_dbg(
ata_link_dbg(
ata_port_dbg(
ath_dbg(
atm_dbg(
bat_dbg(
bit_dbg(
cafe_dev_dbg(
cam_dbg(
c_freq_dbg(
chan_dbg(
chan_reg_rule_print_dbg(
cmm_dbg(
c_pm_dbg(
ctrl_dbg(
__dbg(
desc_dbg(
dev_dbg(
dev_vdbg(
dma_request_channel_dbg(
__dump_desc_dbg(
dump_desc_dbg(
dump_pq_desc_dbg(
dynamic_dev_dbg(
e_dbg(
ehca_dbg(
ehca_gen_dbg(
ehci_dbg(
ehci_vdbg(
en_dbg(
ep_dbg(
ep_vdbg(
fhci_dbg(
fhci_vdbg(
fit_dbg(
gig_dbg(
gpio_dbg(
gru_dbg(
hgpk_dbg(
hid_dbg(
hw_dbg(
ibmvfc_dbg(
ipath_dbg(
ipoib_dbg(
ipr_dbg(
iser_dbg(
isp_isr_dbg(
itd_dbg(
ite_dbg(
l_dbg(
lg_dbg(
mce_dbg(
memblock_dbg(
mhwmp_dbg(
mpeg_dbg(
mpl_dbg(
msg_dbg(
mthca_dbg(
netdev_dbg(
netdev_vdbg(
netif_dbg(
netif_vdbg(
nfc_dbg(
nfc_dev_dbg(
nsp_dbg(
nvt_dbg(
ohci_dbg(
ohci_vdbg(
oxu_dbg(
oxu_vdbg(
pch_dbg(
pch_pci_dbg(
pm_dev_dbg(
pnp_dbg(
pop_dbg(
prep_dma_pq_dbg(
prep_dma_pqzero_sum_dbg(
prep_dma_xor_dbg(
_print_dbg(
print_dbg(
pwm_dbg(
rdev_dbg(
reg_dbg(
sh_keysc_map_dbg(
slice_dbg(
smsc_dbg(
start_dbg(
stop_dbg(
sysrq_handle_dbg(
tda_dbg(
tgt_dbg(
tipc_msg_dbg(
__tuner_dbg(
tuner_dbg(
tveeprom_dbg(
tx_dbg(
uea_dbg(
uea_vdbg(
ugeth_dbg(
ugeth_vdbg(
urb_dbg(
usb_dbg(
vpif_dbg(
wiphy_dbg(
wiphy_vdbg(
xhci_dbg(
x_show_dbg(
