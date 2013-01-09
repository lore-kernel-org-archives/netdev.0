From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Wed, 09 Jan 2013 09:09:32 -0800
Message-ID: <1357751372.27446.40.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 <1357750898.27446.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>
To: Christian Becker <c.becker@traviangames.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57755 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123Ab3AIRJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:09:35 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so1157145pad.9
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 09:09:35 -0800 (PST)
In-Reply-To: <1357750898.27446.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-09 at 09:01 -0800, Eric Dumazet wrote:
> On Wed, 2013-01-09 at 13:01 +0000, Christian Becker wrote:
> > Hi,
> >=20
> > we=C2=B4ve installed 3.7.1 yesterday on one of our loadbalancer nod=
es in order to get TFO.
> >=20
> > Unfortunately the kernel started to print warnings every couple of =
minutes when using tcp splicing in haproxy.
> >=20
> > We=C2=B4ve built the kernel yesterday from the 3.7.1 sources withou=
t any modifications.
> >=20
> > The System contains two Intel Xeon X6550, 64 GB RAM and there are t=
wo kinds of NICs:
> >=20
> > Broadcom Corporation NetXtreme II BCM5709 (Driver bnx2)
> > Emulex Corporation OneConnect 10Gb NIC (Driver be2net)
> >=20
> > The bnx2 adapters are not in use and disconnected and the be2net ha=
ndle about 1 GBit/s of traffic.
> >=20
> > We=C2=B4ve downgraded again to our old kernel version, but i guess =
you should take a look at this.
> >=20
> > There are two kinds of messages:
> >=20
> > an  9 11:34:28 srv11 kernel: [ 1081.334970] ------------[ cut here =
]------------
> > Jan  9 11:34:28 srv11 kernel: [ 1081.353685] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:34:28 srv11 kernel: [ 1081.371956] Hardware name: System =
x3690 X5 -[7148Z68]-
> > Jan  9 11:34:28 srv11 kernel: [ 1081.391820] cleanup rbuf bug: copi=
ed AD3BCF1 seq AD370AF rcvnxt AD3CF13
> > Jan  9 11:34:28 srv11 kernel: [ 1081.408971] Modules linked in: 802=
1q garp stp llc nls_utf8 nls_cp437 vfat fat kvm_intel coretemp kvm joyd=
ev acpi_cpufreq mperf crc32c_intel hid_generic shpchp snd_pcm snd_timer=
 snd lpc_ich mfd_core cdc_ether usb
> > net mii evdev serio_raw ioatdma processor i2c_i801 tpm_tis dca soun=
dcore snd_page_alloc pcspkr tpm microcode i2c_core tpm_bios thermal_sys=
 button pci_hotplug ext4 mbcache jbd2 crc16 dm_mod sg sr_mod cdrom sd_m=
od crc_t10dif usbhid ata_generic hi
> > d uhci_hcd ata_piix libata megaraid_sas bnx2 ehci_hcd usbcore scsi_=
mod usb_common be2net
> > Jan  9 11:34:28 srv11 kernel: [ 1081.532314] Pid: 13763, comm: hapr=
oxy Not tainted 3.7.1 #1
> > Jan  9 11:34:28 srv11 kernel: [ 1081.554349] Call Trace:
> > Jan  9 11:34:28 srv11 kernel: [ 1081.573762]  [<ffffffff8103ef70>] =
? warn_slowpath_common+0x78/0x8c
> > Jan  9 11:34:28 srv11 kernel: [ 1081.596750]  [<ffffffff8103f023>] =
? warn_slowpath_fmt+0x45/0x4a
> > Jan  9 11:34:28 srv11 kernel: [ 1081.617853]  [<ffffffff81297d06>] =
? sock_pipe_buf_release+0xe/0xe
> > Jan  9 11:34:28 srv11 kernel: [ 1081.639111]  [<ffffffff812d37c2>] =
? tcp_cleanup_rbuf+0x4d/0xfc
> > Jan  9 11:34:28 srv11 kernel: [ 1081.661541]  [<ffffffff812d39f4>] =
? tcp_read_sock+0x183/0x194
> > Jan  9 11:34:28 srv11 kernel: [ 1081.681164]  [<ffffffff812d423d>] =
? tcp_sendpage+0x45b/0x45b
> > Jan  9 11:34:28 srv11 kernel: [ 1081.703355]  [<ffffffff812d3ad8>] =
? tcp_splice_read+0xd3/0x223
> > Jan  9 11:34:28 srv11 kernel: [ 1081.724912]  [<ffffffff8112d9b9>] =
? sys_splice+0x345/0x3c0
> > Jan  9 11:34:28 srv11 kernel: [ 1081.744525]  [<ffffffff81364b69>] =
? system_call_fastpath+0x16/0x1b
> > Jan  9 11:34:28 srv11 kernel: [ 1081.766683] ---[ end trace fb4ffd7=
49d51e56f ]---
> >=20
> > Jan  9 11:52:42 srv11 kernel: [ 2174.882971] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:42 srv11 kernel: [ 2174.901182] Hardware name: System =
x3690 X5 -[7148Z68]-
> > Jan  9 11:52:42 srv11 kernel: [ 2174.921229] recvmsg bug 2: copied =
4B9C4CE6 seq 4B9BE950 rcvnxt 4B9C4CE6 fl 0
> > Jan  9 11:52:42 srv11 kernel: [ 2174.941681] Modules linked in: 802=
1q garp stp llc nls_utf8 nls_cp437 vfat fat kvm_intel coretemp kvm joyd=
ev acpi_cpufreq mperf crc32c_intel hid_generic shpchp snd_pcm snd_timer=
 snd lpc_ich mfd_core cdc_ether usb
> > net mii evdev serio_raw ioatdma processor i2c_i801 tpm_tis dca soun=
dcore snd_page_alloc pcspkr tpm microcode i2c_core tpm_bios thermal_sys=
 button pci_hotplug ext4 mbcache jbd2 crc16 dm_mod sg sr_mod cdrom sd_m=
od crc_t10dif usbhid ata_generic hi
> > d uhci_hcd ata_piix libata megaraid_sas bnx2 ehci_hcd usbcore scsi_=
mod usb_common be2net
> > Jan  9 11:52:42 srv11 kernel: [ 2175.075389] Pid: 13250, comm: hapr=
oxy Tainted: G        W    3.7.1 #1
> > Jan  9 11:52:42 srv11 kernel: [ 2175.099391] Call Trace:
> > Jan  9 11:52:42 srv11 kernel: [ 2175.122727]  [<ffffffff8103ef70>] =
? warn_slowpath_common+0x78/0x8c
> > Jan  9 11:52:42 srv11 kernel: [ 2175.147250]  [<ffffffff8103f023>] =
? warn_slowpath_fmt+0x45/0x4a
> > Jan  9 11:52:42 srv11 kernel: [ 2175.170289]  [<ffffffff81295f64>] =
? release_sock+0xe6/0x11c
> > Jan  9 11:52:43 srv11 kernel: [ 2175.192639]  [<ffffffff812d45d2>] =
? tcp_recvmsg+0x2ca/0x9de
> > Jan  9 11:52:43 srv11 kernel: [ 2175.215020]  [<ffffffff812e0b71>] =
? tcp_write_xmit+0x849/0x946
> > Jan  9 11:52:43 srv11 kernel: [ 2175.237682]  [<ffffffff812f2720>] =
? inet_recvmsg+0x64/0x75
> > Jan  9 11:52:43 srv11 kernel: [ 2175.259727]  [<ffffffff8129052d>] =
? sock_recvmsg+0x56/0x6e
> > Jan  9 11:52:43 srv11 kernel: [ 2175.281111]  [<ffffffff8128fedf>] =
? sockfd_lookup_light+0x1a/0x50
> > Jan  9 11:52:43 srv11 kernel: [ 2175.300573]  [<ffffffff812923f4>] =
? sys_recvfrom+0xbf/0x120
> > Jan  9 11:52:43 srv11 kernel: [ 2175.320073]  [<ffffffff8135d9f7>] =
? __schedule+0x4c9/0x4f6
> > Jan  9 11:52:43 srv11 kernel: [ 2175.341151]  [<ffffffff81364b69>] =
? system_call_fastpath+0x16/0x1b
> > Jan  9 11:52:43 srv11 kernel: [ 2175.360859] ---[ end trace fb4ffd7=
49d51e5a7 ]---
> >=20
> > As you can see here, the messages are appearing every couple of min=
utes:
> >=20
> > Jan  9 11:34:28 srv11 kernel: [ 1081.353685] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:34:29 srv11 kernel: [ 1081.809446] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:34:29 srv11 kernel: [ 1082.235052] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:29 srv11 kernel: [ 1082.692732] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:30 srv11 kernel: [ 1083.177807] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:30 srv11 kernel: [ 1083.698475] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:31 srv11 kernel: [ 1084.221899] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:31 srv11 kernel: [ 1084.746992] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:34:32 srv11 kernel: [ 1085.267199] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:16 srv11 kernel: [ 1249.252200] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:17 srv11 kernel: [ 1249.782915] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:17 srv11 kernel: [ 1250.315653] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:18 srv11 kernel: [ 1250.867306] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:18 srv11 kernel: [ 1251.383968] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:19 srv11 kernel: [ 1251.897631] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:19 srv11 kernel: [ 1252.412535] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:37:20 srv11 kernel: [ 1252.921313] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:13 srv11 kernel: [ 1425.644620] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:13 srv11 kernel: [ 1426.314292] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:14 srv11 kernel: [ 1426.749374] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:14 srv11 kernel: [ 1427.198672] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:15 srv11 kernel: [ 1427.711731] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:40:15 srv11 kernel: [ 1428.189284] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:40:16 srv11 kernel: [ 1428.701230] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:09 srv11 kernel: [ 1781.780019] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:09 srv11 kernel: [ 1782.350094] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:10 srv11 kernel: [ 1782.853933] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:10 srv11 kernel: [ 1783.303487] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:11 srv11 kernel: [ 1783.757022] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:11 srv11 kernel: [ 1784.260932] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:12 srv11 kernel: [ 1784.874611] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:13 srv11 kernel: [ 1785.457209] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:13 srv11 kernel: [ 1785.933210] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:14 srv11 kernel: [ 1786.400550] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:14 srv11 kernel: [ 1786.941620] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:15 srv11 kernel: [ 1787.510305] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:15 srv11 kernel: [ 1788.077590] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:54 srv11 kernel: [ 1827.316572] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:55 srv11 kernel: [ 1827.721460] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:55 srv11 kernel: [ 1828.150593] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:56 srv11 kernel: [ 1828.620180] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:56 srv11 kernel: [ 1829.120693] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:46:57 srv11 kernel: [ 1829.597494] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:57 srv11 kernel: [ 1830.189551] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:58 srv11 kernel: [ 1830.745157] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:58 srv11 kernel: [ 1831.299635] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:46:59 srv11 kernel: [ 1831.852929] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:47:00 srv11 kernel: [ 1832.408950] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:52:38 srv11 kernel: [ 2170.882305] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:52:39 srv11 kernel: [ 2171.342827] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:39 srv11 kernel: [ 2171.853599] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:40 srv11 kernel: [ 2172.355757] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:40 srv11 kernel: [ 2172.856194] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:41 srv11 kernel: [ 2173.357738] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:41 srv11 kernel: [ 2173.857774] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:42 srv11 kernel: [ 2174.361131] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> > Jan  9 11:52:42 srv11 kernel: [ 2174.882971] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:43 srv11 kernel: [ 2175.397627] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:43 srv11 kernel: [ 2175.911679] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:44 srv11 kernel: [ 2176.424397] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:44 srv11 kernel: [ 2176.940545] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:45 srv11 kernel: [ 2177.456173] WARNING: at net/ipv4/t=
cp.c:1639 tcp_recvmsg+0x2ca/0x9de()
> > Jan  9 11:52:45 srv11 kernel: [ 2177.971222] WARNING: at net/ipv4/t=
cp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()--
>=20
> Thanks for this report
>=20
> This might be a bug because of TCP collapsing
>=20
> A "netstat -s" would  have been a very useful information.
>=20
>=20

My feeling is that tcp_recv_skb() should eat skbs instead of only
finding the right one

Thats because skb_splice_bits() releases the socket lock before calling
splice_to_pipe()

Once socket is released, other incoming TCP frames can be processed, an=
d
the skb we are actually processing might be 'collapsed' into smaller
units.

Christian, if I send you patches, are you OK to test them ?
