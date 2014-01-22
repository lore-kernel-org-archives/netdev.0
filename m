From: Craig Small <csmall@enc.com.au>
Subject: Re: r8169 won't transmit with 3.12
Date: Wed, 22 Jan 2014 11:41:20 +1100
Message-ID: <20140122004119.GA28174@enc.com.au>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:7579 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbaAVAl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:41:26 -0500
Content-Disposition: inline
In-Reply-To: <20140121233630.GA3214@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
  Thanks for looking into this.
On Wed, Jan 22, 2014 at 12:36:30AM +0100, Francois Romieu wrote:
> You may check that the onboard nic device does not even work when the
> extra PCI-e card aren't plugged.
It definitely doesn't. I've tried with only the onboard device
and no other NIC device (r8169 or not) installed and its the same
problem.

> A complete dmesg including the XID lines that the r8169 driver prints
> would be welcome.
See attached text file. I'm not sure why I get so many interface up
messages. This is for the two NIC cards. I can pull them out and go back
to the onboard one if you like.

I don't see that transmit queue timeout message that often. It looks
like it might happen once per boot and then giveup.

> Please increase the driver verbosity with the 'msglvl' option of ethtool.
I set it at 65535 but it didn't seem to make much difference.

If I:
  * rmmod r8169
  * modprobe r8169 debug=1
  * ifconfig eth0 ....
  * ethtool -s eth0 msglvl 65535
  * ping -I eth0 ...
I get the following:

[1256123.142885] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[1256123.142905] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have ASPM control
[1256123.143182] r8169 0000:03:00.0: irq 73 for MSI/MSI-X
[1256123.154873] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[1256123.154896] r8169 0000:06:00.0: can't disable ASPM; OS doesn't have ASPM control
[1256123.155148] r8169 0000:06:00.0: irq 74 for MSI/MSI-X
[1256182.169596] r8169 0000:03:00.0 eth0: link down
[1256182.169618] r8169 0000:03:00.0 eth0: link down
[1256185.546908] r8169 0000:03:00.0 eth0: link up
[1256228.041490] r8169 0000:03:00.0 eth0: link up

 - Craig
-- 
Craig Small (@smallsees)   http://enc.com.au/       csmall at : enc.com.au
Debian GNU/Linux           http://www.debian.org/   csmall at : debian.org
GPG fingerprint:        5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169dmesg.txt"
Content-Transfer-Encoding: quoted-printable

Jan  7 21:13:52 elmo kernel: [    0.924084] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:13:52 elmo kernel: [    0.924100] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:13:52 elmo kernel: [    0.924315] r8169 0000:03:00.0: irq 72 for =
MSI/MSI-X
Jan  7 21:13:52 elmo kernel: [    0.924474] r8169 0000:03:00.0 eth0: RTL816=
8c/8111c at 0xffffc90001820000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 72
Jan  7 21:13:52 elmo kernel: [    0.924477] r8169 0000:03:00.0 eth0: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:13:52 elmo kernel: [    0.925663] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:13:52 elmo kernel: [    0.925678] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:13:52 elmo kernel: [    0.925983] r8169 0000:06:00.0: irq 74 for =
MSI/MSI-X
Jan  7 21:13:52 elmo kernel: [    0.926424] r8169 0000:06:00.0 eth1: RTL816=
8c/8111c at 0xffffc90001870000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  7 21:13:52 elmo kernel: [    0.926427] r8169 0000:06:00.0 eth1: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:13:54 elmo kernel: [   22.478851] r8169 0000:03:00.0 eth2: link d=
own
Jan  7 21:13:54 elmo kernel: [   22.498863] r8169 0000:06:00.0 eth3: link d=
own
Jan  7 21:21:57 elmo kernel: [    0.921374] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:21:57 elmo kernel: [    0.921385] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:21:57 elmo kernel: [    0.921559] r8169 0000:03:00.0: irq 73 for =
MSI/MSI-X
Jan  7 21:21:57 elmo kernel: [    0.921724] r8169 0000:03:00.0 eth0: RTL816=
8c/8111c at 0xffffc90001824000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 73
Jan  7 21:21:57 elmo kernel: [    0.921730] r8169 0000:03:00.0 eth0: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:21:57 elmo kernel: [    0.924400] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:21:57 elmo kernel: [    0.924411] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:21:57 elmo kernel: [    0.924593] r8169 0000:06:00.0: irq 74 for =
MSI/MSI-X
Jan  7 21:21:57 elmo kernel: [    0.924745] r8169 0000:06:00.0 eth1: RTL816=
8c/8111c at 0xffffc9000187c000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  7 21:21:57 elmo kernel: [    0.924747] r8169 0000:06:00.0 eth1: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:21:57 elmo kernel: [   20.188523] r8169 0000:06:00.0 eth1: link d=
own
Jan  7 21:21:58 elmo kernel: [   43.722301] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:31:36 elmo kernel: [    0.920953] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:31:36 elmo kernel: [    0.920965] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:31:36 elmo kernel: [    0.921184] r8169 0000:03:00.0: irq 72 for =
MSI/MSI-X
Jan  7 21:31:36 elmo kernel: [    0.921329] r8169 0000:03:00.0 eth0: RTL816=
8c/8111c at 0xffffc90001820000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 72
Jan  7 21:31:36 elmo kernel: [    0.921332] r8169 0000:03:00.0 eth0: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:31:36 elmo kernel: [    0.921407] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:31:36 elmo kernel: [    0.921414] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:31:36 elmo kernel: [    0.921586] r8169 0000:06:00.0: irq 73 for =
MSI/MSI-X
Jan  7 21:31:36 elmo kernel: [    0.921719] r8169 0000:06:00.0 eth1: RTL816=
8c/8111c at 0xffffc90001824000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 73
Jan  7 21:31:36 elmo kernel: [    0.921722] r8169 0000:06:00.0 eth1: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:31:36 elmo kernel: [   20.712240] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:31:36 elmo kernel: [   20.712321] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:31:36 elmo kernel: [   23.934160] r8169 0000:03:00.0 eth0: link up
Jan  7 21:31:36 elmo kernel: [   51.528553] r8169 0000:06:00.0 eth1: link d=
own
Jan  7 21:31:36 elmo kernel: [   51.528628] r8169 0000:06:00.0 eth1: link d=
own
Jan  7 21:31:36 elmo kernel: [   53.825413] NETDEV WATCHDOG: eth0 (r8169): =
transmit queue 0 timed out
Jan  7 21:31:36 elmo kernel: [   53.825416] Modules linked in: ip6t_REJECT =
nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipt_REJECT xt_t=
cpudp xt_LOG xt_mac nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntr=
ack iptable_filter ip_tables x_tables fuse it87 hwmon_vid loop tda18271 tda=
10048 joydev hid_generic snd_hda_codec_hdmi usbhid hid evdev kvm_amd kvm cr=
c32_pclmul crc32c_intel ghash_clmulni_intel raid1 aesni_intel aes_x86_64 ab=
lk_helper cryptd lrw gf128mul glue_helper md_mod psmouse sp5100_tco pcspkr =
fam15h_power serio_raw edac_mce_amd edac_core k10temp i2c_piix4 nouveau snd=
_hda_codec_via mxm_wmi wmi saa7164 video ttm drm_kms_helper tveeprom dvb_co=
re snd_hda_intel v4l2_common drm snd_hda_codec videodev snd_hwdep media snd=
_pcm i2c_algo_bit snd_page_alloc acpi_cpufreq i2c_core snd_timer snd button=
 processor soundcore thermal_sys ext4 crc16 mbcache jbd2 dm_mod sg sd_mod s=
r_mod cdrom crc_t10dif crct10dif_common ahci libahci ehci_pci libata ohci_p=
ci ohci_hcd ehci_hcd xhci_hcd scsi_mod r8169 mii usbcore usb_common
Jan  7 21:31:36 elmo kernel: [   53.857677] r8169 0000:03:00.0 eth0: link up
Jan  7 21:31:36 elmo kernel: [   54.324015] r8169 0000:06:00.0 eth1: link up
Jan  7 21:31:37 elmo kernel: [   83.826545] r8169 0000:03:00.0 eth0: link up
Jan  7 21:31:44 elmo kernel: [   90.822740] r8169 0000:06:00.0 eth1: link up
Jan  7 21:31:49 elmo kernel: [   95.822969] r8169 0000:03:00.0 eth0: link up
Jan  7 21:32:01 elmo kernel: [  107.832103] r8169 0000:03:00.0 eth0: link up
Jan  7 21:32:02 elmo kernel: [  108.807299] r8169 0000:06:00.0 eth1: link up
Jan  7 21:32:13 elmo kernel: [  119.816649] r8169 0000:03:00.0 eth0: link up
Jan  7 21:32:25 elmo kernel: [  131.813620] r8169 0000:03:00.0 eth0: link up
Jan  7 21:32:55 elmo kernel: [  161.774516] r8169 0000:03:00.0 eth0: link up
Jan  7 21:33:13 elmo kernel: [  179.768739] r8169 0000:03:00.0 eth0: link up
Jan  7 21:33:37 elmo kernel: [  203.758175] r8169 0000:03:00.0 eth0: link up
Jan  7 21:34:19 elmo kernel: [  245.709869] r8169 0000:03:00.0 eth0: link up
Jan  7 21:35:01 elmo kernel: [  287.693507] r8169 0000:03:00.0 eth0: link up
Jan  7 21:35:31 elmo kernel: [  317.654398] r8169 0000:03:00.0 eth0: link up
Jan  7 21:36:01 elmo kernel: [  347.647293] r8169 0000:03:00.0 eth0: link up
Jan  7 21:36:37 elmo kernel: [  383.606973] r8169 0000:03:00.0 eth0: link up
Jan  7 21:37:01 elmo kernel: [  407.633061] r8169 0000:03:00.0 eth0: link up
Jan  7 21:37:19 elmo kernel: [  425.571252] r8169 0000:03:00.0 eth0: link up
Jan  7 21:38:47 elmo kernel: [  513.921118] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:38:47 elmo kernel: [  513.921136] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:38:47 elmo kernel: [  513.921421] r8169 0000:03:00.0: irq 72 for =
MSI/MSI-X
Jan  7 21:38:47 elmo kernel: [  513.921795] r8169 0000:03:00.0 eth0: RTL816=
8c/8111c at 0xffffc90001820000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 72
Jan  7 21:38:47 elmo kernel: [  513.921802] r8169 0000:03:00.0 eth0: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:38:47 elmo kernel: [  513.927502] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:38:47 elmo kernel: [  513.927525] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:38:47 elmo kernel: [  513.927767] r8169 0000:06:00.0: irq 73 for =
MSI/MSI-X
Jan  7 21:38:47 elmo kernel: [  513.928204] r8169 0000:06:00.0 eth1: RTL816=
8c/8111c at 0xffffc90001824000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 73
Jan  7 21:38:47 elmo kernel: [  513.928211] r8169 0000:06:00.0 eth1: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:39:08 elmo kernel: [  534.217262] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:39:08 elmo kernel: [  534.217274] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:39:11 elmo kernel: [  537.473818] r8169 0000:03:00.0 eth0: link up
Jan  7 21:39:23 elmo kernel: [  549.508735] r8169 0000:03:00.0 eth0: link up
Jan  7 21:39:35 elmo kernel: [  561.479471] r8169 0000:03:00.0 eth0: link up
Jan  7 21:39:53 elmo kernel: [  579.541748] r8169 0000:03:00.0 eth0: link up
Jan  7 21:40:29 elmo kernel: [  615.580750] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:40:29 elmo kernel: [  615.580771] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:40:29 elmo kernel: [  615.581034] r8169 0000:03:00.0: irq 72 for =
MSI/MSI-X
Jan  7 21:40:29 elmo kernel: [  615.586376] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:40:29 elmo kernel: [  615.586395] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:40:29 elmo kernel: [  615.586632] r8169 0000:06:00.0: irq 73 for =
MSI/MSI-X
Jan  7 21:45:36 elmo kernel: [    0.924701] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:45:36 elmo kernel: [    0.924807] r8169 0000:03:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:45:36 elmo kernel: [    0.925414] r8169 0000:03:00.0: irq 72 for =
MSI/MSI-X
Jan  7 21:45:36 elmo kernel: [    0.925768] r8169 0000:03:00.0 eth0: RTL816=
8c/8111c at 0xffffc90001820000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 72
Jan  7 21:45:36 elmo kernel: [    0.925771] r8169 0000:03:00.0 eth0: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:45:36 elmo kernel: [    0.925797] r8169 Gigabit Ethernet driver 2=
=2E3LK-NAPI loaded
Jan  7 21:45:36 elmo kernel: [    0.925804] r8169 0000:06:00.0: can't disab=
le ASPM; OS doesn't have ASPM control
Jan  7 21:45:36 elmo kernel: [    0.925981] r8169 0000:06:00.0: irq 73 for =
MSI/MSI-X
Jan  7 21:45:36 elmo kernel: [    0.926099] r8169 0000:06:00.0 eth1: RTL816=
8c/8111c at 0xffffc90001824000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 73
Jan  7 21:45:36 elmo kernel: [    0.926101] r8169 0000:06:00.0 eth1: jumbo =
features [frames: 6128 bytes, tx checksumming: ko]
Jan  7 21:45:36 elmo kernel: [   21.831549] r8169 0000:03:00.0 eth0: link d=
own
Jan  7 21:45:44 elmo kernel: [   42.735362] r8169 0000:06:00.0 eth1: link d=
own
Jan  7 21:45:44 elmo kernel: [   42.735371] r8169 0000:06:00.0 eth1: link d=
own
Jan  7 21:45:47 elmo kernel: [   45.491721] r8169 0000:06:00.0 eth1: link up
Jan  7 21:47:59 elmo kernel: [  177.794729] NETDEV WATCHDOG: eth1 (r8169): =
transmit queue 0 timed out
Jan  7 21:47:59 elmo kernel: [  177.794732] Modules linked in: ip6t_REJECT =
nf_conntrack_ipv6 nf_defrag_ipv6 bnep rfcomm bluetooth rfkill vhost_net vho=
st macvtap macvlan tun ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_CHE=
CKSUM iptable_mangle bridge stp llc xt_multiport ip6table_filter ip6_tables=
 ebtable_nat ebtables parport_pc ppdev lp parport binfmt_misc ipt_REJECT xt=
_tcpudp xt_LOG xt_mac nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conn=
track iptable_filter ip_tables x_tables fuse it87 hwmon_vid loop tda18271 t=
da10048 joydev hid_generic snd_hda_codec_hdmi usbhid hid evdev raid1 md_mod=
 kvm_amd kvm crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_=
x86_64 ablk_helper cryptd lrw gf128mul glue_helper psmouse pcspkr serio_raw=
 k10temp edac_mce_amd fam15h_power sp5100_tco edac_core nouveau snd_hda_cod=
ec_via i2c_piix4 mxm_wmi saa7164 wmi video ttm tveeprom drm_kms_helper dvb_=
core v4l2_common drm videodev media i2c_algo_bit snd_hda_intel i2c_core snd=
_hda_codec acpi_cpufreq snd_hwdep processor button snd_pcm snd_page_alloc s=
nd_timer thermal_sys snd soundcore ext4 crc16 mbcache jbd2 dm_mod sg sd_mod=
 sr_mod cdrom crc_t10dif crct10dif_common 8139too ehci_pci ahci ohci_pci oh=
ci_hcd ehci_hcd libahci xhci_hcd r8169 mii usbcore libata usb_common scsi_m=
od
Jan  7 21:47:59 elmo kernel: [  177.803038] r8169 0000:06:00.0 eth1: link up
Jan  7 21:55:13 elmo kernel: [  611.228156] Modules linked in: r8168(O) ip6=
t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 bnep rfcomm bluetooth rfkill vhos=
t_net vhost macvtap macvlan tun ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_n=
at xt_CHECKSUM iptable_mangle bridge stp llc xt_multiport ip6table_filter i=
p6_tables ebtable_nat ebtables parport_pc ppdev lp parport binfmt_misc ipt_=
REJECT xt_tcpudp xt_LOG xt_mac nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrac=
k nf_conntrack iptable_filter ip_tables x_tables fuse it87 hwmon_vid loop t=
da18271 tda10048 joydev hid_generic snd_hda_codec_hdmi usbhid hid evdev rai=
d1 md_mod kvm_amd kvm crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_i=
ntel aes_x86_64 ablk_helper cryptd lrw gf128mul glue_helper psmouse pcspkr =
serio_raw k10temp edac_mce_amd fam15h_power sp5100_tco edac_core nouveau sn=
d_hda_codec_via i2c_piix4 mxm_wmi saa7164 wmi video ttm tveeprom drm_kms_he=
lper dvb_core v4l2_common drm videodev media i2c_algo_bit snd_hda_intel i2c=
_core snd_hda_codec acpi_cpufreq snd_hwdep processor button snd_pcm snd_pag=
e_alloc snd_timer thermal_sys snd soundcore ext4 crc16 mbcache jbd2 dm_mod =
sg sd_mod sr_mod cdrom crc_t10dif crct10dif_common 8139too ehci_pci ahci oh=
ci_pci ohci_hcd ehci_hcd libahci xhci_hcd mii usbcore libata usb_common scs=
i_mod [last unloaded: r8169]
Jan  9 08:52:26 elmo kernel: [124556.014238] r8169 Gigabit Ethernet driver =
2.3LK-NAPI loaded
Jan  9 08:52:26 elmo kernel: [124556.014257] r8169 0000:03:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 08:52:26 elmo kernel: [124556.014508] r8169 0000:03:00.0: irq 73 for=
 MSI/MSI-X
Jan  9 08:52:26 elmo kernel: [124556.014791] r8169 0000:03:00.0 eth0: RTL81=
68c/8111c at 0xffffc90001870000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 73
Jan  9 08:52:26 elmo kernel: [124556.014799] r8169 0000:03:00.0 eth0: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 08:52:26 elmo kernel: [124556.014984] r8169 Gigabit Ethernet driver =
2.3LK-NAPI loaded
Jan  9 08:52:26 elmo kernel: [124556.015001] r8169 0000:06:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 08:52:26 elmo kernel: [124556.015248] r8169 0000:06:00.0: irq 74 for=
 MSI/MSI-X
Jan  9 08:52:26 elmo kernel: [124556.015509] r8169 0000:06:00.0 eth1: RTL81=
68c/8111c at 0xffffc9000187e000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  9 08:52:26 elmo kernel: [124556.015515] r8169 0000:06:00.0 eth1: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 08:52:26 elmo kernel: [124556.056527] r8169 0000:03:00.0 eth0: link =
down
Jan  9 08:52:27 elmo kernel: [124557.661174] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:52:52 elmo kernel: [124582.349643] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:53:46 elmo kernel: [124636.305529] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:54:36 elmo kernel: [124686.536235] r8169 Gigabit Ethernet driver =
2.3LK-NAPI loaded
Jan  9 08:54:36 elmo kernel: [124686.536260] r8169 0000:03:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 08:54:36 elmo kernel: [124686.536512] r8169 0000:03:00.0: irq 73 for=
 MSI/MSI-X
Jan  9 08:54:36 elmo kernel: [124686.536805] r8169 0000:03:00.0 eth0: RTL81=
68c/8111c at 0xffffc90001870000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 73
Jan  9 08:54:36 elmo kernel: [124686.536812] r8169 0000:03:00.0 eth0: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 08:54:36 elmo kernel: [124686.547745] r8169 Gigabit Ethernet driver =
2.3LK-NAPI loaded
Jan  9 08:54:36 elmo kernel: [124686.547769] r8169 0000:06:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 08:54:36 elmo kernel: [124686.548024] r8169 0000:06:00.0: irq 74 for=
 MSI/MSI-X
Jan  9 08:54:36 elmo kernel: [124686.555383] r8169 0000:03:00.0 eth0: link =
down
Jan  9 08:54:36 elmo kernel: [124686.555396] r8169 0000:03:00.0 eth0: link =
down
Jan  9 08:54:36 elmo kernel: [124686.555635] r8169 0000:06:00.0 eth1: RTL81=
68c/8111c at 0xffffc9000187e000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  9 08:54:36 elmo kernel: [124686.555640] r8169 0000:06:00.0 eth1: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 08:54:40 elmo kernel: [124690.143434] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:55:40 elmo kernel: [124750.245190] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:56:28 elmo kernel: [124798.267925] r8169 0000:03:00.0 eth0: link =
up
Jan  9 08:58:16 elmo kernel: [124906.124315] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:00:34 elmo kernel: [125043.447578] r8169 0000:03:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 09:00:34 elmo kernel: [125043.447833] r8169 0000:03:00.0: irq 73 for=
 MSI/MSI-X
Jan  9 09:00:34 elmo kernel: [125043.448156] r8169 0000:03:00.0 eth0: RTL81=
68c/8111c at 0xffffc90001870000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 73
Jan  9 09:00:34 elmo kernel: [125043.448162] r8169 0000:03:00.0 eth0: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 09:00:34 elmo kernel: [125043.460502] r8169 0000:06:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 09:00:34 elmo kernel: [125043.460705] r8169 0000:06:00.0: irq 74 for=
 MSI/MSI-X
Jan  9 09:00:34 elmo kernel: [125043.467175] r8169 0000:06:00.0 eth1: RTL81=
68c/8111c at 0xffffc9000187e000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  9 09:00:34 elmo kernel: [125043.467181] r8169 0000:06:00.0 eth1: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 09:09:00 elmo kernel: [125549.128197] r8169 0000:03:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 09:09:00 elmo kernel: [125549.128457] r8169 0000:03:00.0: irq 73 for=
 MSI/MSI-X
Jan  9 09:09:00 elmo kernel: [125549.128748] r8169 0000:03:00.0 eth0: RTL81=
68c/8111c at 0xffffc90001870000, 00:e0:4c:80:66:57, XID 1c4000c0 IRQ 73
Jan  9 09:09:00 elmo kernel: [125549.128755] r8169 0000:03:00.0 eth0: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 09:09:00 elmo kernel: [125549.145664] r8169 0000:06:00.0: can't disa=
ble ASPM; OS doesn't have ASPM control
Jan  9 09:09:00 elmo kernel: [125549.145934] r8169 0000:06:00.0: irq 74 for=
 MSI/MSI-X
Jan  9 09:09:00 elmo kernel: [125549.146934] r8169 0000:03:00.0 eth0: link =
down
Jan  9 09:09:00 elmo kernel: [125549.147189] r8169 0000:06:00.0 eth1: RTL81=
68c/8111c at 0xffffc9000187e000, 00:e0:4c:80:70:08, XID 1c4000c0 IRQ 74
Jan  9 09:09:00 elmo kernel: [125549.147193] r8169 0000:06:00.0 eth1: jumbo=
 features [frames: 6128 bytes, tx checksumming: ko]
Jan  9 09:09:00 elmo kernel: [125549.147234] r8169 0000:03:00.0 eth0: link =
down
Jan  9 09:09:03 elmo kernel: [125552.943570] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:09:28 elmo kernel: [125577.579875] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:10:34 elmo kernel: [125643.518729] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:11:04 elmo kernel: [125673.505548] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:11:52 elmo kernel: [125721.462613] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:12:22 elmo kernel: [125751.445129] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:13:31 elmo kernel: [125820.588517] r8169 0000:03:00.0 eth0: link =
down
Jan  9 09:13:31 elmo kernel: [125820.588524] r8169 0000:03:00.0 eth0: link =
down
Jan  9 09:13:34 elmo kernel: [125823.765570] r8169 0000:03:00.0 eth0: link =
up
Jan  9 09:13:59 elmo kernel: [125848.409967] r8169 0000:03:00.0 eth0: link =
up
Jan  9 10:56:59 elmo kernel: [132023.485940] r8169 0000:03:00.0 eth0: link =
down
Jan  9 11:02:14 elmo kernel: [132338.259437] r8169 0000:03:00.0 eth0: link =
up
Jan  9 11:02:15 elmo kernel: [132338.888600] r8169 0000:03:00.0 eth0: link =
down
Jan  9 11:02:17 elmo kernel: [132340.899557] r8169 0000:03:00.0 eth0: link =
up
Jan  9 12:21:59 elmo kernel: [137119.706747] r8169 0000:03:00.0 eth0: link =
up
Jan  9 13:46:58 elmo kernel: [142215.007812] r8169 0000:03:00.0 eth0: link =
down
Jan  9 13:51:11 elmo kernel: [142467.021851] r8169 0000:03:00.0 eth0: link =
up
Jan  9 13:51:12 elmo kernel: [142468.036445] r8169 0000:03:00.0 eth0: link =
down
Jan  9 13:51:13 elmo kernel: [142469.683089] r8169 0000:03:00.0 eth0: link =
up
Jan  9 14:22:01 elmo kernel: [144316.058860] r8169 0000:03:00.0 eth0: link =
up
Jan 10 00:15:01 elmo kernel: [179868.506724] r8169 0000:03:00.0 eth0: link =
up
Jan 10 01:34:07 elmo kernel: [184610.809173] r8169 0000:03:00.0 eth0: link =
up
Jan 10 06:27:19 elmo kernel: [202189.245589] r8169 0000:03:00.0 eth0: link =
up
Jan 10 10:25:17 elmo kernel: [216458.170910] r8169 0000:03:00.0 eth0: link =
up
Jan 10 10:50:23 elmo kernel: [217963.001075] r8169 0000:03:00.0 eth0: link =
up
Jan 10 11:04:29 elmo kernel: [218808.352269] r8169 0000:03:00.0 eth0: link =
up
Jan 10 11:27:35 elmo kernel: [220193.304666] r8169 0000:03:00.0 eth0: link =
up
Jan 10 11:50:23 elmo kernel: [221560.241410] r8169 0000:03:00.0 eth0: link =
up
Jan 10 12:05:59 elmo kernel: [222495.539781] r8169 0000:03:00.0 eth0: link =
up
Jan 10 12:29:41 elmo kernel: [223916.436973] r8169 0000:03:00.0 eth0: link =
up
Jan 10 12:51:23 elmo kernel: [225217.437479] r8169 0000:03:00.0 eth0: link =
up
Jan 10 13:04:53 elmo kernel: [226026.817632] r8169 0000:03:00.0 eth0: link =
up
Jan 10 13:28:47 elmo kernel: [227459.718466] r8169 0000:03:00.0 eth0: link =
up
Jan 10 13:51:35 elmo kernel: [228826.681757] r8169 0000:03:00.0 eth0: link =
up
Jan 10 14:03:41 elmo kernel: [229552.123700] r8169 0000:03:00.0 eth0: link =
up
Jan 10 14:26:23 elmo kernel: [230913.072252] r8169 0000:03:00.0 eth0: link =
up
Jan 10 14:47:11 elmo kernel: [232160.105546] r8169 0000:03:00.0 eth0: link =
up
Jan 10 15:12:11 elmo kernel: [233658.974021] r8169 0000:03:00.0 eth0: link =
up
Jan 10 15:29:29 elmo kernel: [234696.177510] r8169 0000:03:00.0 eth0: link =
up
Jan 10 15:50:23 elmo kernel: [235949.197834] r8169 0000:03:00.0 eth0: link =
up
Jan 10 16:13:17 elmo kernel: [237322.147870] r8169 0000:03:00.0 eth0: link =
up
Jan 10 16:34:17 elmo kernel: [238581.179914] r8169 0000:03:00.0 eth0: link =
up
Jan 10 16:59:23 elmo kernel: [240086.040262] r8169 0000:03:00.0 eth0: link =
up
Jan 10 17:14:59 elmo kernel: [241021.338493] r8169 0000:03:00.0 eth0: link =
up
Jan 10 17:36:29 elmo kernel: [242310.318221] r8169 0000:03:00.0 eth0: link =
up
Jan 10 18:00:29 elmo kernel: [243749.209619] r8169 0000:03:00.0 eth0: link =
up
Jan 10 18:24:17 elmo kernel: [245176.117274] r8169 0000:03:00.0 eth0: link =
up
Jan 10 18:47:11 elmo kernel: [246549.108048] r8169 0000:03:00.0 eth0: link =
up
Jan 10 19:02:35 elmo kernel: [247472.355174] r8169 0000:03:00.0 eth0: link =
up
Jan 10 19:26:47 elmo kernel: [248923.303384] r8169 0000:03:00.0 eth0: link =
up
Jan 10 19:50:47 elmo kernel: [250362.144802] r8169 0000:03:00.0 eth0: link =
up
Jan 10 20:13:29 elmo kernel: [251723.101783] r8169 0000:03:00.0 eth0: link =
up
Jan 10 20:35:29 elmo kernel: [253042.081251] r8169 0000:03:00.0 eth0: link =
up
Jan 10 20:59:29 elmo kernel: [254480.981747] r8169 0000:03:00.0 eth0: link =
up
Jan 10 21:22:17 elmo kernel: [255847.927367] r8169 0000:03:00.0 eth0: link =
up
Jan 10 21:46:11 elmo kernel: [257280.835154] r8169 0000:03:00.0 eth0: link =
up
Jan 10 22:10:35 elmo kernel: [258743.709869] r8169 0000:03:00.0 eth0: link =
up
Jan 10 22:25:23 elmo kernel: [259631.016371] r8169 0000:03:00.0 eth0: link =
up
Jan 10 22:49:47 elmo kernel: [261093.912822] r8169 0000:03:00.0 eth0: link =
up
Jan 10 23:14:29 elmo kernel: [262574.775599] r8169 0000:03:00.0 eth0: link =
up
Jan 10 23:41:05 elmo kernel: [264169.532821] r8169 0000:03:00.0 eth0: link =
up
Jan 11 00:20:29 elmo kernel: [266531.713878] r8169 0000:03:00.0 eth0: link =
up
Jan 11 01:08:29 elmo kernel: [269409.500032] r8169 0000:03:00.0 eth0: link =
up
Jan 11 01:22:35 elmo kernel: [270254.861202] r8169 0000:03:00.0 eth0: link =
up
Jan 11 01:45:53 elmo kernel: [271651.779561] r8169 0000:03:00.0 eth0: link =
up
Jan 11 02:09:29 elmo kernel: [273066.706131] r8169 0000:03:00.0 eth0: link =
up
Jan 11 02:25:11 elmo kernel: [274008.016185] r8169 0000:03:00.0 eth0: link =
up
Jan 11 02:48:53 elmo kernel: [275428.884591] r8169 0000:03:00.0 eth0: link =
up
Jan 11 03:14:05 elmo kernel: [276939.735485] r8169 0000:03:00.0 eth0: link =
up
Jan 11 03:55:29 elmo kernel: [279421.824429] r8169 0000:03:00.0 eth0: link =
up
Jan 11 04:42:29 elmo kernel: [282239.665715] r8169 0000:03:00.0 eth0: link =
up
Jan 11 05:26:05 elmo kernel: [284853.658781] r8169 0000:03:00.0 eth0: link =
up
Jan 11 06:14:05 elmo kernel: [287731.454199] r8169 0000:03:00.0 eth0: link =
up
Jan 11 06:25:11 elmo kernel: [288396.950192] r8169 0000:03:00.0 eth0: link =
up
Jan 11 06:41:23 elmo kernel: [289368.205492] r8169 0000:03:00.0 eth0: link =
up
Jan 11 07:05:29 elmo kernel: [290813.090764] r8169 0000:03:00.0 eth0: link =
up
Jan 11 07:28:11 elmo kernel: [292174.044720] r8169 0000:03:00.0 eth0: link =
up
Jan 11 07:52:23 elmo kernel: [293624.947008] r8169 0000:03:00.0 eth0: link =
up
Jan 11 08:16:17 elmo kernel: [295057.821023] r8169 0000:03:00.0 eth0: link =
up
Jan 11 08:30:35 elmo kernel: [295915.174546] r8169 0000:03:00.0 eth0: link =
up
Jan 11 08:56:41 elmo kernel: [297479.953856] r8169 0000:03:00.0 eth0: link =
up
Jan 11 09:20:41 elmo kernel: [298918.875097] r8169 0000:03:00.0 eth0: link =
up
Jan 11 09:42:29 elmo kernel: [300225.856036] r8169 0000:03:00.0 eth0: link =
up
Jan 11 10:05:17 elmo kernel: [301592.816385] r8169 0000:03:00.0 eth0: link =
up
Jan 11 10:22:47 elmo kernel: [302642.021483] r8169 0000:03:00.0 eth0: link =
up
Jan 11 10:46:41 elmo kernel: [304074.915787] r8169 0000:03:00.0 eth0: link =
up
Jan 11 11:12:47 elmo kernel: [305639.727570] r8169 0000:03:00.0 eth0: link =
up
Jan 11 11:43:17 elmo kernel: [307468.308263] r8169 0000:03:00.0 eth0: link =
up
Jan 11 11:56:53 elmo kernel: [308283.696450] r8169 0000:03:00.0 eth0: link =
up
Jan 11 12:19:47 elmo kernel: [309656.641788] r8169 0000:03:00.0 eth0: link =
up
Jan 11 12:43:05 elmo kernel: [311053.560314] r8169 0000:03:00.0 eth0: link =
up
Jan 11 13:07:47 elmo kernel: [312534.418463] r8169 0000:03:00.0 eth0: link =
up
Jan 11 13:30:41 elmo kernel: [313907.365171] r8169 0000:03:00.0 eth0: link =
up
Jan 11 13:54:17 elmo kernel: [315322.276762] r8169 0000:03:00.0 eth0: link =
up
Jan 11 14:18:47 elmo kernel: [316791.163514] r8169 0000:03:00.0 eth0: link =
up
Jan 11 14:42:29 elmo kernel: [318212.066921] r8169 0000:03:00.0 eth0: link =
up
Jan 11 15:07:47 elmo kernel: [319728.890740] r8169 0000:03:00.0 eth0: link =
up
Jan 11 15:22:47 elmo kernel: [320628.199976] r8169 0000:03:00.0 eth0: link =
up
Jan 11 15:46:41 elmo kernel: [322061.101203] r8169 0000:03:00.0 eth0: link =
up
Jan 11 16:09:59 elmo kernel: [323458.047578] r8169 0000:03:00.0 eth0: link =
up
Jan 11 16:32:29 elmo kernel: [324807.000015] r8169 0000:03:00.0 eth0: link =
up
Jan 11 16:56:17 elmo kernel: [326233.897558] r8169 0000:03:00.0 eth0: link =
up
Jan 11 17:19:23 elmo kernel: [327618.832116] r8169 0000:03:00.0 eth0: link =
up
Jan 11 17:42:17 elmo kernel: [328991.781805] r8169 0000:03:00.0 eth0: link =
up
Jan 11 17:58:29 elmo kernel: [329963.040468] r8169 0000:03:00.0 eth0: link =
up
Jan 11 18:19:29 elmo kernel: [331222.061017] r8169 0000:03:00.0 eth0: link =
up
Jan 11 18:43:17 elmo kernel: [332648.954572] r8169 0000:03:00.0 eth0: link =
up
Jan 11 19:12:53 elmo kernel: [334423.600928] r8169 0000:03:00.0 eth0: link =
up
Jan 11 19:54:23 elmo kernel: [336911.694736] r8169 0000:03:00.0 eth0: link =
up
Jan 11 20:08:29 elmo kernel: [337757.063044] r8169 0000:03:00.0 eth0: link =
up
Jan 11 20:32:17 elmo kernel: [339183.947065] r8169 0000:03:00.0 eth0: link =
up
Jan 11 20:56:41 elmo kernel: [340646.830012] r8169 0000:03:00.0 eth0: link =
up
Jan 11 21:12:35 elmo kernel: [341600.106319] r8169 0000:03:00.0 eth0: link =
up
Jan 11 21:34:59 elmo kernel: [342943.072953] r8169 0000:03:00.0 eth0: link =
up
Jan 11 21:58:23 elmo kernel: [344346.010377] r8169 0000:03:00.0 eth0: link =
up
Jan 11 22:27:29 elmo kernel: [346090.650653] r8169 0000:03:00.0 eth0: link =
up
Jan 11 22:39:29 elmo kernel: [346810.097681] r8169 0000:03:00.0 eth0: link =
up
Jan 11 23:03:05 elmo kernel: [348225.015098] r8169 0000:03:00.0 eth0: link =
up
Jan 11 23:26:29 elmo kernel: [349627.946117] r8169 0000:03:00.0 eth0: link =
up
Jan 11 23:41:41 elmo kernel: [350539.240694] r8169 0000:03:00.0 eth0: link =
up
Jan 12 00:05:41 elmo kernel: [351978.133377] r8169 0000:03:00.0 eth0: link =
up
Jan 12 00:28:05 elmo kernel: [353321.087554] r8169 0000:03:00.0 eth0: link =
up
Jan 12 01:12:17 elmo kernel: [355971.080348] r8169 0000:03:00.0 eth0: link =
up
Jan 12 01:58:17 elmo kernel: [358728.956382] r8169 0000:03:00.0 eth0: link =
up
Jan 12 02:44:11 elmo kernel: [361480.834141] r8169 0000:03:00.0 eth0: link =
up
Jan 12 03:33:35 elmo kernel: [364442.572951] r8169 0000:03:00.0 eth0: link =
up
Jan 12 03:44:29 elmo kernel: [365096.063835] r8169 0000:03:00.0 eth0: link =
up
Jan 12 04:10:41 elmo kernel: [366666.862665] r8169 0000:03:00.0 eth0: link =
up
Jan 12 04:35:17 elmo kernel: [368141.719614] r8169 0000:03:00.0 eth0: link =
up
Jan 12 04:50:59 elmo kernel: [369083.003813] r8169 0000:03:00.0 eth0: link =
up
Jan 12 05:14:53 elmo kernel: [370515.900323] r8169 0000:03:00.0 eth0: link =
up
Jan 12 05:37:53 elmo kernel: [371894.857820] r8169 0000:03:00.0 eth0: link =
up
Jan 12 05:53:05 elmo kernel: [372806.157333] r8169 0000:03:00.0 eth0: link =
up
Jan 12 06:15:59 elmo kernel: [374179.086690] r8169 0000:03:00.0 eth0: link =
up

--azLHFNyN32YCQGCU--
