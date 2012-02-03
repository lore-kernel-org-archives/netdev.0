From: Alban Browaeys <prahal@yahoo.com>
Subject: Re: skge - no traffic and oops after ifdown - 3.3-rc1 main tree
 (resend)
Date: Fri, 03 Feb 2012 01:56:27 +0100
Message-ID: <1327688328.8784.2.camel@penelope>
References: <1327662357.4461.5.camel@penelope>
	 <20120127091831.49ba7e68@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mTswHeIc5QNqZbaKWDfb"
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm20-vm2.bullet.mail.ne1.yahoo.com ([98.138.91.208]:43861 "HELO
	nm20-vm2.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753570Ab2BCA4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 19:56:30 -0500
In-Reply-To: <20120127091831.49ba7e68@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mTswHeIc5QNqZbaKWDfb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

Le vendredi 27 janvier 2012 à 09:18 -0800, Stephen Hemminger a écrit :
> On Fri, 27 Jan 2012 12:05:57 +0100
> Alban Browaeys <prahal@yahoo.com> wrote:
> 
> > I opened https://bugzilla.kernel.org/show_bug.cgi?id=42665 namely oops
> > attachement and :
> > 
> > skge crash after attempt to setup as dhcp then ifdown
> > 
> > commit d0249e44432aa0ffcf710b64449b8eaa3722547e
> > Author: stephen hemminger <shemminger@vyatta.com>
> > Date:   Thu Jan 19 14:37:18 2012 +0000
> > 
> >     skge: check for PCI dma mapping errors
> > 
> >     Driver should check for mapping errors.
> >     Machines with limited DMA maps may return an error when a PCI map is
> >     requested (not an issue on standard x86).
> > 
> >     Also use upper/lower 32 bits macros for clarity.
> > 
> >     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > 
> > leads to failure to ifup <skge interface> if this one is setup as dhcp (static
> > "works" but no traffic) then an ifdown leads to the attached oops.
> > 
> > Reverting this commit fixes both issues (traffic and ifdown) at least until
> > mainline tree commit 87f71ae2dd7471c1b4c94100be1f218e91dc64c3 .
> > 
> > 
> >   *-network:2
> >        description: Ethernet interface
> >        produit: 88E8001 Gigabit Ethernet Controller
> >        fabriquant: Marvell Technology Group Ltd.
> >        identifiant matériel: d
> >        information bus: pci@0000:01:0d.0
> >        nom logique: eth0
> >        version: 13
> >        numéro de série: 00:18:f3:02:33:79
> >        taille: 100Mbit/s
> >        capacité: 1Gbit/s
> >        bits: 32 bits
> >        horloge: 66MHz
> >        fonctionnalités: bus_master cap_list rom ethernet physical tp 10bt
> > 10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
> >        configuration: autonegotiation=on broadcast=yes driver=skge
> > driverversion=1.14 duplex=full latency=64 maxlatency=31 mingnt=23 multicast=yes
> > port=twisted pair promiscuous=yes speed=100Mbit/s
> >        ressources: irq:23 mémoire:fbff8000-fbffbfff portE/S:d400(taille=256)
> > mémoire:fbfa0000-fbfbffff
> > 
> > 
> > 
> > 01:0d.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit
> > Ethernet Controller (rev 13)
> >     Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit Ethernet
> > Controller (Asus)
> >     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> > Stepping- SERR+ FastB2B- DisINTx-
> >     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort-
> > <MAbort- >SERR- <PERR- INTx-
> >     Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 16 bytes
> >     Interrupt: pin A routed to IRQ 23
> >     Region 0: Memory at fbff8000 (32-bit, non-prefetchable) [size=16K]
> >     Region 1: I/O ports at d400 [size=256]
> >     Expansion ROM at fbfa0000 [disabled] [size=128K]
> >     Capabilities: <access denied>
> >     Kernel driver in use: skge
> > 
> > 01:0d.0 0200: 11ab:4320 (rev 13)
> >     Subsystem: 1043:811a
> > 
> > arch i686.
> > 
> > 
> > 
> > Best regards,
> > Alban
> > 
> 
> Could you send me the backtrace from the OOPS?
> 
it was in the bug report :) Here it is . Looking at objdump -S output
this happens in skge_rx_clean call to dev_kfree_skb.

BR,
Alban

--=-mTswHeIc5QNqZbaKWDfb
Content-Disposition: attachment; filename="skge_oops_cleanup.log"
Content-Type: text/x-log; name="skge_oops_cleanup.log"; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Jan 26 21:51:08 argos kernel: [   48.008701] skge 0000:01:0d.0: eth0: enabl=
ing interface
Jan 26 21:51:08 argos kernel: [   48.016621] ADDRCONF(NETDEV_UP): eth0: lin=
k is not ready
Jan 26 21:51:08 argos kernel: [   49.699046] skge 0000:01:0d.0: eth0: Link =
is up at 100 Mbps, full duplex, flow control none
Jan 26 21:51:08 argos kernel: [   49.699260] ADDRCONF(NETDEV_CHANGE): eth0:=
 link becomes ready
Jan 26 21:51:08 argos kernel: [  111.867228] r8169 0000:02:00.0: eth2: link=
 down
Jan 26 21:51:08 argos kernel: [  111.867645] ADDRCONF(NETDEV_UP): eth2: lin=
k is not ready
Jan 26 21:51:08 argos kernel: [  116.304445] fuse init (API version 7.18)
Jan 26 21:51:08 argos kernel: [  116.331325] microcode: CPU0 sig=3D0xf49, p=
f=3D0x10, revision=3D0x3
Jan 26 21:51:08 argos kernel: [  116.450048] microcode: CPU1 sig=3D0xf49, p=
f=3D0x10, revision=3D0x3
Jan 26 21:51:08 argos kernel: [  116.525728] microcode: Microcode Update Dr=
iver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
Jan 26 21:51:08 argos kernel: [  117.307287] ip6_tables: (C) 2000-2006 Netf=
ilter Core Team
Jan 26 21:51:08 argos kernel: [  120.331326] Netfilter messages via NETLINK=
 v0.30.
Jan 26 21:51:08 argos kernel: [  120.424883] nf_conntrack version 0.5.0 (16=
384 buckets, 65536 max)
Jan 26 21:51:08 argos kernel: [  121.305848] NF_TPROXY: Transparent proxy s=
upport initialized, version 4.1.0
Jan 26 21:51:08 argos kernel: [  121.305858] NF_TPROXY: Copyright (c) 2006-=
2007 BalaBit IT Ltd.
Jan 26 21:51:08 argos kernel: [  121.415848] xt_time: kernel timezone is -0=
000
Jan 26 21:51:08 argos kernel: [  121.625482] ctnetlink v0.93: registering w=
ith nfnetlink.
Jan 26 21:51:08 argos kernel: [  121.910017] ip_set: protocol 6
Jan 26 21:51:08 argos kernel: [  122.540480] ipt_CLUSTERIP: ClusterIP Versi=
on 0.8 loaded successfully
Jan 26 21:51:08 argos kernel: [  126.868419] u32 classifier
Jan 26 21:51:08 argos kernel: [  126.868426]     Performance counters on
Jan 26 21:51:08 argos kernel: [  126.868432]     input device check on
Jan 26 21:51:08 argos kernel: [  126.868436]     Actions configured
Jan 26 21:51:30 argos kernel: [  213.759071] NOHZ: local_softirq_pending 08
Jan 26 21:54:24 argos kernel: [  386.872163] skge 0000:01:0d.0: eth0: disab=
ling interface
Jan 26 21:54:24 argos kernel: [  386.874682] BUG: unable to handle kernel N=
ULL pointer dereference at 00000114
Jan 26 21:54:24 argos kernel: [  386.876036] IP: [<c10ad7d6>] put_page+0x6/=
0x28
Jan 26 21:54:24 argos kernel: [  386.876036] *pdpt =3D 000000002215e001 *pd=
e =3D 0000000000000000=20
Jan 26 21:54:24 argos kernel: [  386.876036] Oops: 0000 [#1] SMP=20
Jan 26 21:54:24 argos kernel: [  386.888522] Modules linked in: snd_hrtimer=
 mperf cpufreq_userspace cpufreq_powersave cpufreq_conservative parport_pc =
parport act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_h=
fsc sch_htb sch_ingress sch_sfq xt_realm xt_addrtype xt_connlimit iptable_r=
aw xt_comment ipt_ULOG xt_recent ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MAS=
QUERADE ipt_ECN ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_snmp_basic nf_connt=
rack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre ip6_queue nf_nat_irc nf_n=
at_h323 nf_nat_ftp xt_set nf_nat_amanda ip_set nf_conntrack_tftp nf_conntra=
ck_sip nf_conntrack_sane nf_conntrack_proto_udplite nf_conntrack_proto_sctp=
 nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack=
_netbios_ns nf_conntrack_broadcast ts_kmp nf_conntrack_amanda nf_conntrack_=
irc nf_conntrack_h323 xt_time nf_conntrack_ftp xt_TCPMSS xt_sctp xt_TPROXY =
nf_tproxy_core xt_tcpmss xt_policy xt_pkttype xt_physdev xt_owner xt_NFQUEU=
E xt_NFLOG nfnetlink_log xt_multiport xt_mark xt_mac xt_limit xt_length xt_=
iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASS=
IFY xt_AUDIT ip6t_LOG ipt_LOG ip6t_REJECT xt_tcpudp xt_state iptable_nat nf=
_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_c=
onntrack ip6table_raw nf_conntrack ip6table_mangle iptable_mangle nfnetlink=
 ip6table_filter ip6_tables microcode fuse iptable_filter ip_tables x_table=
s openvswitch_mod(O) deflate ctr twofish_generic twofish_i586 twofish_commo=
n camellia serpent_generic cast5 des_generic cbc aes_i586 aes_generic xcbc =
rmd160 sha512_generic sha256_generic sha1_generic hmac crypto_null af_key t=
hermal ac eeprom w83781d i2c_dev w83627ehf hwmon_vid 8021q garp stp dm_cryp=
t snd_intel8x0 snd_ac97_codec arc4 ac97_bus snd_pcm_oss snd_mixer_oss snd_p=
cm snd_seq_midi snd_rawmidi r8169 ath5k snd_seq_midi_event ath mac80211 joy=
dev snd_seq pcmcia snd_timer snd_seq_device yenta_socket pcmcia_rsrc snd cf=
g80211 pcmcia_core psmouse rfkill pcspkr soundcore snd_page_alloc shpchp se=
rio_raw pci_hotplug iTCO_wdt iTCO_vendor_support processor evdev ext3 jbd m=
bcache btrfs zlib_deflate crc32c libcrc32c dm_mod hid_logitech ff_memless u=
sbhid hid power_supply sd_mod crc_t10dif sr_mod cdrom ata_generic i915 drm_=
kms_helper drm ata_piix uhci_hcd libata ehci_hcd via_rhine skge mii scsi_mo=
d usbcore i2c_algo_bit button i2c_core video usb_common thermal_sys [last u=
nloaded: scsi_wait_scan]
Jan 26 21:54:24 argos kernel: [  386.888522]=20
Jan 26 21:54:24 argos kernel: [  386.888522] Pid: 6246, comm: ifconfig Tain=
ted: G           O 3.3.0-rc1+ #56 System manufacturer System Product Name/P=
5PE-VM
Jan 26 21:54:24 argos kernel: [  386.888522] EIP: 0060:[<c10ad7d6>] EFLAGS:=
 00010203 CPU: 1
Jan 26 21:54:24 argos kernel: [  386.888522] EIP is at put_page+0x6/0x28
Jan 26 21:54:24 argos kernel: [  386.888522] EAX: 00000114 EBX: 00000114 EC=
X: 00000088 EDX: 00000002
Jan 26 21:54:24 argos kernel: [  386.888522] ESI: 00000001 EDI: f56eab80 EB=
P: e217dddc ESP: e217ddd8
Jan 26 21:54:24 argos kernel: [  386.888522]  DS: 007b ES: 007b FS: 00d8 GS=
: 00e0 SS: 0068
Jan 26 21:54:24 argos kernel: [  386.888522] Process ifconfig (pid: 6246, t=
i=3De217c000 task=3Def473010 task.ti=3De217c000)
Jan 26 21:54:24 argos kernel: [  386.888522] Stack:
Jan 26 21:54:24 argos kernel: [  386.888522]  f4604780 e217ddec c122feda f4=
604780 f50eddc0 e217ddf8 c122ff42 f4604780
Jan 26 21:54:24 argos kernel: [  386.888522]  e217de08 c122ffed f4c9e060 f5=
0eddc0 e217de1c f9ade5f2 f56eab80 f50ed800
Jan 26 21:54:24 argos kernel: [  386.888522]  f50eddc0 e217de44 f9adf5d9 f5=
ea21c0 00000000 00000000 000006b4 00000434
Jan 26 21:54:24 argos kernel: [  386.888522] Call Trace:
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c122feda>] skb_release_data=
+0x49/0x9f
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c122ff42>] __kfree_skb+0x12=
/0x6f
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c122ffed>] consume_skb+0x4e=
/0x52
Jan 26 21:54:24 argos kernel: [  386.888522]  [<f9ade5f2>] skge_rx_clean+0x=
34/0x4a [skge]
Jan 26 21:54:24 argos kernel: [  386.888522]  [<f9adf5d9>] skge_down+0x430/=
0x47c [skge]
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c12360f0>] __dev_close_many=
+0x6f/0x91
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c1236133>] __dev_close+0x21=
/0x32
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c1239adc>] __dev_change_fla=
gs+0x97/0x10e
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c1239bb7>] dev_change_flags=
+0x13/0x3f
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c127d62a>] devinet_ioctl+0x=
23a/0x4df
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c127dd5c>] inet_ioctl+0x82/=
0x9b
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c1228a7e>] sock_ioctl+0x1ce=
/0x1f0
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c12288b0>] ? sock_fasync+0x=
6a/0x6a
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c10e8abc>] do_vfs_ioctl+0x4=
4b/0x47f
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c10488c7>] ? up_read+0x16/0=
x29
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c12e63d7>] ? do_page_fault+=
0x2bd/0x2ea
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c10e8b31>] sys_ioctl+0x41/0=
x64
Jan 26 21:54:24 argos kernel: [  386.888522]  [<c12e7edf>] sysenter_do_call=
+0x12/0x38
Jan 26 21:54:24 argos kernel: [  386.888522] Code: c3 55 ba 29 d8 0a c1 89 =
e5 51 8d 4d fc c7 45 fc 00 00 00 00 e8 3d ff ff ff 8b 45 fc 64 01 05 dc 5e =
65 c1 c9 c3 55 89 e5 53 89 c3 <f7> 03 00 c0 00 00 74 07 e8 2d fd ff ff eb 1=
0 e8 a8 f8 ff ff 85=20
Jan 26 21:54:24 argos kernel: [  386.888522] EIP: [<c10ad7d6>] put_page+0x6=
/0x28 SS:ESP 0068:e217ddd8
Jan 26 21:54:24 argos kernel: [  386.888522] CR2: 0000000000000114
Jan 26 21:54:24 argos kernel: [  387.049739] ---[ end trace 690545842305552=
7 ]---


--=-mTswHeIc5QNqZbaKWDfb--
