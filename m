From: Andreas Mohr <andi@lisas.de>
Subject: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by ISDN
Date: Sun, 7 Oct 2007 14:06:53 +0200
Message-ID: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: isdn4linux@listserv.isdn4linux.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:35462 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbXJGMRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 08:17:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[not necessarily a very recent regression, used 2.6.19 kernels before...]

Hi all,

wondered why my main internet server (headless!) didn't come up properly
on a new 2.6.23-rc8-mm2
(connections almost completely refused: firewalling not executed due to
earlier OOPS?).
Upon LILO emergency fallback into an older version (2.6.16...) saw this
in /var/log/messages:

Oct  7 13:07:34 gate kernel: e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
Oct  7 13:07:34 gate kernel: e100: Copyright(c) 1999-2006 Intel Corporation
Oct  7 13:07:34 gate kernel: Atmel at76x USB Wireless LAN Driver 0.16 loading
Oct  7 13:07:34 gate kernel: eth2: MAC address 00:05:5d:95:ab:f0
Oct  7 13:07:34 gate kernel: eth2: firmware version 1.101.5-84
Oct  7 13:07:34 gate kernel: eth2: regulatory domain 0x30: ETSI (most of Europe)
Oct  7 13:07:34 gate kernel: usbcore: registered new interface driver at76_usb
Oct  7 13:07:34 gate kernel: Netfilter messages via NETLINK v0.30.
Oct  7 13:07:34 gate kernel: nf_conntrack version 0.5.0 (2048 buckets, 8192 max)
Oct  7 13:07:34 gate kernel: nf_conntrack_ipv4: Unknown parameter `hashsize'
Oct  7 13:07:34 gate kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Oct  7 13:07:34 gate kernel: process `syslogd' is using obsolete setsockopt SO_BSD
COMPAT
Oct  7 13:07:40 gate kernel: ------------[ cut here ]------------
Oct  7 13:07:40 gate kernel: kernel BUG at net/core/dev.c:3485!
Oct  7 13:07:40 gate kernel: invalid opcode: 0000 [#1]
Oct  7 13:07:40 gate kernel: last sysfs file: /devices/platform/sis5595.656/temp1_
max
Oct  7 13:07:40 gate kernel: Modules linked in: xt_state xt_limit xt_tcpudp xt_mul
tiport iptable_mangle iptable_nat nf_conntrack_ipv4 iptable_filter ip_tables nf_na
t_tftp nf_conntrack_tftp nf_nat_h323 nf_conntrack_h323 nf_nat_irc nf_nat_ftp nf_co
nntrack_irc nf_conntrack_ftp ipt_MASQUERADE nf_nat nf_conntrack nfnetlink ipt_REJE
CT ipt_LOG x_tables at76_usb firmware_class e100 ohci_hcd usbcore i2c_sis630 i2c_s
is5595 i2c_core sis5595 hisax isdn eepro100
Oct  7 13:07:40 gate kernel:
Oct  7 13:07:40 gate kernel: Pid: 2235, comm: isdnctrl Not tainted (2.6.23-rc8-mm2
-gate #1)
Oct  7 13:07:40 gate kernel: EIP: 0060:[<c029ad8a>] EFLAGS: 00010246 CPU: 0
Oct  7 13:07:40 gate kernel: EIP is at register_netdevice+0x6d/0x2c1
Oct  7 13:07:40 gate kernel: EAX: 00000000 EBX: c786501c ECX: 00000000 EDX: 00000d
99
Oct  7 13:07:40 gate kernel: ESI: c786501c EDI: 00000000 EBP: c1657d08 ESP: c1657c
ec
Oct  7 13:07:40 gate kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Oct  7 13:07:40 gate kernel: Process isdnctrl (pid: 2235, ti=c1656000 task=c14c306
0 task.ti=c1656000)
Oct  7 13:07:40 gate kernel: Stack: c786501c 00000000 c1657d00 c0309ec6 c1657d68 c
786501c 00000000 c1657d18
Oct  7 13:07:40 gate kernel:        c029b010 c1657d68 c7865000 c1657d38 c885a0fa c
884e39c c8864598 c786501c
Oct  7 13:07:40 gate kernel:        c1657d68 00000000 bfbf779d c1657f60 c886484d c
212ef80 c1561980 c1805ab0
Oct  7 13:07:40 gate kernel: Call Trace:
Oct  7 13:07:40 gate kernel:  [<c029b010>] register_netdev+0x32/0x3f
Oct  7 13:07:40 gate kernel:  [<c885a0fa>] isdn_net_new+0x111/0x2ca [isdn]
Oct  7 13:07:40 gate kernel:  [<c886484d>] isdn_ioctl+0x2b5/0xb46 [isdn]
Oct  7 13:07:40 gate kernel:  [<c015f53c>] do_ioctl+0x40/0x50
Oct  7 13:07:40 gate kernel:  [<c015f738>] vfs_ioctl+0x1ec/0x203
Oct  7 13:07:40 gate kernel:  [<c015f780>] sys_ioctl+0x31/0x49
Oct  7 13:07:40 gate kernel:  [<c0103e12>] syscall_call+0x7/0xb
Oct  7 13:07:40 gate kernel:  [<b7f54de4>] 0xb7f54de4
Oct  7 13:07:40 gate kernel:  =======================
Oct  7 13:07:40 gate kernel: Code: e8 3f a5 e6 ff ba 99 0d 00 00 b8 b4 3c 38 c0 e8
 96 82 e7 ff 83 bb 20 02 00 00 00 74 04 0f 0b eb fe 8b 83 80 02 00 00 85 c0 75 04
<0f> 0b eb fe 89 45 f0 b9 4c 2e 48 c0 ba 8e 3e 38 c0 8d 83 78 01
Oct  7 13:07:40 gate kernel: EIP: [<c029ad8a>] register_netdevice+0x6d/0x2c1 SS:ES
P 0068:c1657cec
Oct  7 13:18:17 gate syslogd 1.4.1#20: restart.
Oct  7 13:18:17 gate kernel: klogd 1.4.1#20, log source = /proc/kmsg started.
Oct  7 13:18:17 gate kernel: Linux version 2.6.16-cks11-gate (root@gate) (gcc vers
ion 4.0.4 20060507 (prerelease) (Debian 4.0.3-3)) #1 Sat May 27 14:45:18 CEST 2006

[logging was then back into 2.6.16 above]


2.6.23-rc8-mm2/net/core/dev.c/register_netdevice():

int register_netdevice(struct net_device *dev)
{
        struct hlist_head *head;
        struct hlist_node *p;
        int ret;
        struct net *net;

        BUG_ON(dev_boot_phase);
        ASSERT_RTNL();

        might_sleep();

        /* When net_device's are persistent, this will be fatal. */
        BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
        BUG_ON(!dev->nd_net);
        net = dev->nd_net;

        spin_lock_init(&dev->queue_lock);
        spin_lock_init(&dev->_xmit_lock);
        netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
        dev->xmit_lock_owner = -1;
        spin_lock_init(&dev->ingress_lock);

        dev->iflink = -1;

        /* Init, if this function is available */
        if (dev->init) {
                ret = dev->init(dev);
                if (ret) {
                        if (ret > 0)
                                ret = -EIO;
                        goto out;
                }
        }


objdump -D linux-2.6.23-rc8-mm2/vmlinux|less :

c029ad1d <register_netdevice>:
c029ad1d:       55                      push   %ebp
c029ad1e:       89 e5                   mov    %esp,%ebp
c029ad20:       57                      push   %edi
c029ad21:       56                      push   %esi
c029ad22:       53                      push   %ebx
c029ad23:       89 c3                   mov    %eax,%ebx
c029ad25:       83 ec 10                sub    $0x10,%esp
c029ad28:       83 3d 4c fa 41 c0 00    cmpl   $0x0,0xc041fa4c
c029ad2f:       74 04                   je     c029ad35 <register_netdevice+0x18>
c029ad31:       0f 0b                   ud2a
c029ad33:       eb fe                   jmp    c029ad33 <register_netdevice+0x16>
c029ad35:       e8 7e 7f 00 00          call   c02a2cb8 <rtnl_trylock>
c029ad3a:       85 c0                   test   %eax,%eax
c029ad3c:       74 26                   je     c029ad64 <register_netdevice+0x47>
c029ad3e:       e8 79 78 00 00          call   c02a25bc <rtnl_unlock>
c029ad43:       c7 44 24 08 97 0d 00    movl   $0xd97,0x8(%esp)
c029ad4a:       00
c029ad4b:       c7 44 24 04 b4 3c 38    movl   $0xc0383cb4,0x4(%esp)
c029ad52:       c0
c029ad53:       c7 04 24 c3 3c 38 c0    movl   $0xc0383cc3,(%esp)
c029ad5a:       e8 13 e3 e7 ff          call   c0119072 <printk>
c029ad5f:       e8 3f a5 e6 ff          call   c01052a3 <dump_stack>
c029ad64:       ba 99 0d 00 00          mov    $0xd99,%edx
c029ad69:       b8 b4 3c 38 c0          mov    $0xc0383cb4,%eax
c029ad6e:       e8 96 82 e7 ff          call   c0113009 <__might_sleep>
c029ad73:       83 bb 20 02 00 00 00    cmpl   $0x0,0x220(%ebx)
c029ad7a:       74 04                   je     c029ad80 <register_netdevice+0x63>
c029ad7c:       0f 0b                   ud2a
c029ad7e:       eb fe                   jmp    c029ad7e <register_netdevice+0x61>
c029ad80:       8b 83 80 02 00 00       mov    0x280(%ebx),%eax
c029ad86:       85 c0                   test   %eax,%eax
c029ad88:       75 04                   jne    c029ad8e <register_netdevice+0x71>
c029ad8a:       0f 0b                   ud2a
c029ad8c:       eb fe                   jmp    c029ad8c <register_netdevice+0x6f>
c029ad8e:       89 45 f0                mov    %eax,0xfffffff0(%ebp)
c029ad91:       b9 4c 2e 48 c0          mov    $0xc0482e4c,%ecx
c029ad96:       ba 8e 3e 38 c0          mov    $0xc0383e8e,%edx
c029ad9b:       8d 83 78 01 00 00       lea    0x178(%ebx),%eax
c029ada1:       e8 8e d9 f7 ff          call   c0218734 <__spin_lock_init>
c029ada6:       8d 83 b4 01 00 00       lea    0x1b4(%ebx),%eax
c029adac:       b9 4c 2e 48 c0          mov    $0xc0482e4c,%ecx
c029adb1:       ba 9f 3e 38 c0          mov    $0xc0383e9f,%edx
c029adb6:       e8 79 d9 f7 ff          call   c0218734 <__spin_lock_init>
c029adbb:       ba b0 3e 38 c0          mov    $0xc0383eb0,%edx
c029adc0:       b9 4c 2e 48 c0          mov    $0xc0482e4c,%ecx
c029adc5:       c7 83 c4 01 00 00 ff    movl   $0xffffffff,0x1c4(%ebx)
c029adcc:       ff ff ff
c029adcf:       8d 83 a0 01 00 00       lea    0x1a0(%ebx),%eax
c029add5:       e8 5a d9 f7 ff          call   c0218734 <__spin_lock_init>
c029adda:       8b 53 40                mov    0x40(%ebx),%edx
c029addd:       c7 43 50 ff ff ff ff    movl   $0xffffffff,0x50(%ebx)
c029ade4:       85 d2                   test   %edx,%edx
c029ade6:       74 1b                   je     c029ae03 <register_netdevice+0xe6>

Since EIP is c029ad8a, following the code flow it clearly looks to me
as if it's the
        BUG_ON(!dev->nd_net);
check which caused the BUG message.

This is a K6-3/450@150 running Debian stable.

lsmod (NOTE: this is on 2.6.16!!):

Module                  Size  Used by
sch_ingress             4356  1
cls_u32                 7044  5
sch_tbf                 6272  1
sch_sfq                 5632  4
sch_htb                15616  1
ppp_async              11648  1
crc_ccitt               2176  1 ppp_async
ipt_ULOG                7712  1
xt_state                2176  4
xt_limit                2688  11
xt_tcpudp               3328  48
ipt_multiport           2560  10
iptable_mangle          2816  0
iptable_nat             7684  1
iptable_filter          3072  1
ip_tables              11736  3 iptable_mangle,iptable_nat,iptable_filter
ip_nat_tftp             1920  0
ip_conntrack_tftp       4244  1 ip_nat_tftp
ip_nat_irc              2688  0
ip_nat_ftp              3200  0
ip_conntrack_irc        6680  1 ip_nat_irc
ip_conntrack_ftp        7324  1 ip_nat_ftp
ipt_MASQUERADE          3712  1
ip_nat                 15764  5 iptable_nat,ip_nat_tftp,ip_nat_irc,ip_nat_ftp,ipt_MASQUERADE
ip_conntrack           44196  10 xt_state,iptable_nat,ip_nat_tftp,ip_conntrack_tftp,ip_nat_irc,ip_nat_ftp,ip_conntrack_irc,ip_conntrack_ftp,ipt_MASQUERADE,ip_nat
ipt_REJECT              5248  0
ipt_LOG                 6144  11
x_tables               12292  10 ipt_ULOG,xt_state,xt_limit,xt_tcpudp,ipt_multiport,iptable_nat,ip_tables,ipt_MASQUERADE,ipt_REJECT,ipt_LOG
e100                   33284  0
at76c503_rfmd           5260  0
firmware_class         10112  1 at76c503_rfmd
at76c503               79840  1 at76c503_rfmd
at76_usbdfu             4996  1 at76c503
ohci_hcd               29700  0
usbcore               126240  5 at76c503_rfmd,at76c503,at76_usbdfu,ohci_hcd
i2c_sis630              8844  0
i2c_sis5595             7940  0
sis5595                14216  0
i2c_isa                 5888  1 sis5595
i2c_core               22144  4 i2c_sis630,i2c_sis5595,sis5595,i2c_isa
hisax                 175100  2
isdn                  108864  5 hisax
eepro100               29456  0

root@gate:/usr/src/linux-2.6.23-rc8-mm2/net# dpkg -l|grep isdn
ii  isdnlog                          3.9.20060704-3                   ISDN connection logger
ii  isdnlog-data                     3.9.20060704-3                   data for isdnlog users
ii  isdnutils                        3.9.20060704-3                   Most important ISDN-related packages and uti
ii  isdnutils-base                   3.9.20060704-3                   ISDN utilities, the basic (minimal) set
ii  isdnutils-xtools                 3.9.20060704-3                   ISDN utilities that use X
ii  isdnvboxclient                   3.9.20060704-3                   ISDN answering machine, client
ii  isdnvboxserver                   3.9.20060704-3                   ISDN answering machine, server

CONFIG_ISDN=m
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
# CONFIG_IPPP_FILTER is not set
CONFIG_ISDN_PPP_BSDCOMP=m
CONFIG_ISDN_AUDIO=y
# CONFIG_ISDN_TTY_FAX is not set

#
# ISDN feature submodules
#
CONFIG_ISDN_DRV_LOOP=m
# CONFIG_ISDN_DIVERSION is not set

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
CONFIG_ISDN_DRV_HISAX=m

#
# D-channel protocol features
#
CONFIG_HISAX_EURO=y
CONFIG_DE_AOC=y
# CONFIG_HISAX_NO_SENDCOMPLETE is not set
# CONFIG_HISAX_NO_LLC is not set
# CONFIG_HISAX_NO_KEYPAD is not set
# CONFIG_HISAX_1TR6 is not set
# CONFIG_HISAX_NI1 is not set
CONFIG_HISAX_MAX_CARDS=8

#
# HiSax supported cards
#
# CONFIG_HISAX_16_0 is not set
CONFIG_HISAX_16_3=y
CONFIG_HISAX_TELESPCI=y
# CONFIG_HISAX_S0BOX is not set
# CONFIG_HISAX_AVM_A1 is not set
CONFIG_HISAX_FRITZPCI=y
# CONFIG_HISAX_AVM_A1_PCMCIA is not set
# CONFIG_HISAX_ELSA is not set
# CONFIG_HISAX_IX1MICROR2 is not set
# CONFIG_HISAX_DIEHLDIVA is not set
# CONFIG_HISAX_ASUSCOM is not set
# CONFIG_HISAX_TELEINT is not set
# CONFIG_HISAX_HFCS is not set
# CONFIG_HISAX_SEDLBAUER is not set
CONFIG_HISAX_SPORTSTER=y
# CONFIG_HISAX_MIC is not set
# CONFIG_HISAX_NETJET is not set
# CONFIG_HISAX_NETJET_U is not set
# CONFIG_HISAX_NICCY is not set
# CONFIG_HISAX_ISURF is not set
# CONFIG_HISAX_HSTSAPHIR is not set
# CONFIG_HISAX_BKM_A4T is not set
# CONFIG_HISAX_SCT_QUADRO is not set
# CONFIG_HISAX_GAZEL is not set
CONFIG_HISAX_HFC_PCI=y
CONFIG_HISAX_W6692=y
# CONFIG_HISAX_HFC_SX is not set
# CONFIG_HISAX_DEBUG is not set

#
# HiSax PCMCIA card service modules
#

#
# HiSax sub driver modules
#
# CONFIG_HISAX_ST5481 is not set
# CONFIG_HISAX_HFCUSB is not set
# CONFIG_HISAX_HFC4S8S is not set
CONFIG_HISAX_FRITZ_PCIPNP=m

#
# Active cards
#
# CONFIG_ISDN_DRV_ICN is not set
# CONFIG_ISDN_DRV_PCBIT is not set
# CONFIG_ISDN_DRV_SC is not set
# CONFIG_ISDN_DRV_ACT2000 is not set
# CONFIG_HYSDN is not set
# CONFIG_ISDN_DRV_GIGASET is not set
# CONFIG_ISDN_CAPI is not set
# CONFIG_PHONE is not set


lspci (NOTE: on 2.6.16!!):
00:09.0 Network controller: Cologne Chip Designs GmbH ISDN network controller [HFC-PCI] (rev 02)

I used to have an ISA-based card (Teles?) in there, replaced by the PCI one
about 2 years ago.

grep isdnctrl /etc/isdn/*:

/etc/isdn/device.ippp0:# Read the isdnctrl manpage for more info.
/etc/isdn/device.ippp0: isdnctrl addif ${device}
/etc/isdn/device.ippp0: isdnctrl eaz ${device} $LOCALMSN
/etc/isdn/device.ippp0: # "name". More than one number can be set by calling isdnc
trl addphone
/etc/isdn/device.ippp0:                 isdnctrl addphone ${device} out $LEADINGZE
RO$MSN
/etc/isdn/device.ippp0: # disabled. More than one number can be set by calling isd
nctrl addphone
/etc/isdn/device.ippp0: #               isdnctrl addphone ${device} in $MSN
/etc/isdn/device.ippp0: # been added to the access list with isdnctrl addphone nam
e in.
/etc/isdn/device.ippp0: isdnctrl secure ${device} on
/etc/isdn/device.ippp0: isdnctrl huptimeout ${device} 180       # XXX_
/etc/isdn/device.ippp0: #isdnctrl dialmax ${device} 3
/etc/isdn/device.ippp0: #isdnctrl ihup ${device} on
/etc/isdn/device.ippp0: isdnctrl encap ${device} $ENCAP
/etc/isdn/device.ippp0: isdnctrl l2_prot ${device} hdlc
/etc/isdn/device.ippp0: isdnctrl l3_prot ${device} trans
/etc/isdn/device.ippp0: isdnctrl verbose 2
/etc/isdn/device.ippp0: #isdnctrl chargehup ${device} on
/etc/isdn/device.ippp0: #isdnctrl chargeint ${device} NUM
/etc/isdn/device.ippp0: #isdnctrl callback ${device} MODE
/etc/isdn/device.ippp0: #isdnctrl cbdelay ${device} SECONDS
/etc/isdn/device.ippp0: #isdnctrl cbhup ${device} MODE
/etc/isdn/device.ippp0: # See also : isdnctrl(8), isdnctrl help text
/etc/isdn/device.ippp0:         isdnctrl pppbind ${device} $bindnum
/etc/isdn/device.ippp0: isdnctrl dialmode $device $DIALMODE >/dev/null 2>&1
/etc/isdn/device.ippp0: isdnctrl dialmode $device off >/dev/null 2>&1
/etc/isdn/device.ippp0: isdnctrl delif $device  2> /dev/null
/etc/isdn/init.d.functions:    # can't count on "isdnctrl status all" working yet,
 unfortunately...
/etc/isdn/init.d.functions:     DEVS=`/usr/sbin/isdnctrl list all | grep 'Current
setup' | cut -f2 -d"'" | sort`
/etc/isdn/init.d.functions:         if [ ! -e /dev/isdnctrl ]; then
/etc/isdn/init.d.functions:             cd /dev && ln -s isdnctrl0 isdnctrl
/etc/isdn/init.d.functions:    cardnum=0   # counts in channels, just like /dev/is
dnctrlX
/etc/isdn/init.d.functions:    for optionfile in /etc/isdn/isdnlog.isdnctrl[02468]
; do
/etc/isdn/init.d.functions:        devicenum=${device#isdnctrl}
/etc/isdn/init.d.functions:        # test for isdnctrl dualmode. With dualmode, on
e isdnlog listens to
/etc/isdn/init.d.functions:    for optionfile in /etc/isdn/isdnlog.isdnctrl?; do
/etc/isdn/init.d.functions:    for optionfile in /etc/isdn/isdnlog.isdnctrl?; do
/etc/isdn/init.d.functions:                    /usr/sbin/isdnctrl delif $device >/
dev/null 2>&1 || true
/etc/isdn/init.d.functions:            /usr/sbin/isdnctrl delif $device >/dev/null
 2>&1 || true
/etc/isdn/netdown.old:eval `grep '^     isdnctrl addphone' /etc/isdn/device.ippp0
| sed 's,addphone,delphone,'`
/etc/isdn/netdown.old:/sbin/isdnctrl hangup ippp0
/etc/isdn/netup.old:eval `grep '^       isdnctrl addphone' /etc/isdn/device.ippp0`
/etc/isdn/stop:        /usr/sbin/isdnctrl system off
/etc/isdn/xisdnload-netdown:# script again). So, putting "isdnctrl dialmode all of
f" here is not that
/etc/isdn/xisdnload-netdown:# useful, as you have to do "isdnctrl dialmode all aut
o" manually...
/etc/isdn/xisdnload-netdown:/usr/sbin/isdnctrl hangup ippp0 > /dev/null
/etc/isdn/xmonisdn-netdown:/usr/sbin/isdnctrl dialmode all off
/etc/isdn/xmonisdn-netup:/usr/sbin/isdnctrl dialmode all auto


I intend to still try to get it up and running with 2.6.23-rc8-mm2 today
(with some workarounds hopefully, maybe even disabling ISDN completely)...

The last running kernel (I didn't have newer ones in between), up for some 110
days was 2.6.19-cks2 (IOW, I cannot quite say that
"this is an important regression, it has been broken very recently").

Thanks,

Andreas Mohr
