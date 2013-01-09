From: Christian Becker <c.becker@traviangames.com>
Subject: tainted warnings with tcp splicing in 3.7.1
Date: Wed, 9 Jan 2013 13:01:43 +0000
Message-ID: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx00.traviangames.com ([146.0.3.4]:37935 "EHLO
	mx00.traviangames.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab3AINKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 08:10:16 -0500
Received: from mx00.traviangames.com (localhost [127.0.0.1])
	by mx00.traviangames.com (Postfix) with ESMTP id 7FD0BE2072
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2013 14:01:44 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by mx00.traviangames.com (Postfix) with ESMTP id 7D516E2055
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2013 14:01:44 +0100 (CET)
Received: from mx00.traviangames.com ([127.0.0.1])
	by localhost (mx00.traviangames.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9KfzHGXF25YM for <netdev@vger.kernel.org>;
	Wed,  9 Jan 2013 14:01:44 +0100 (CET)
Received: from exchcl01.muc.traviangames.lan (mucr10053060115.muc.traviangames.lan [10.10.12.44])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mx00.traviangames.com (Postfix) with ESMTPS id 6A714E2040
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2013 14:01:44 +0100 (CET)
Content-Language: de-DE
Content-ID: <F90D5D2F26988D48BC606FDD6D2D670A@muc.traviangames.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we=B4ve installed 3.7.1 yesterday on one of our loadbalancer nodes in o=
rder to get TFO.

Unfortunately the kernel started to print warnings every couple of minu=
tes when using tcp splicing in haproxy.

We=B4ve built the kernel yesterday from the 3.7.1 sources without any m=
odifications.

The System contains two Intel Xeon X6550, 64 GB RAM and there are two k=
inds of NICs:

Broadcom Corporation NetXtreme II BCM5709 (Driver bnx2)
Emulex Corporation OneConnect 10Gb NIC (Driver be2net)

The bnx2 adapters are not in use and disconnected and the be2net handle=
 about 1 GBit/s of traffic.

We=B4ve downgraded again to our old kernel version, but i guess you sho=
uld take a look at this.

There are two kinds of messages:

an  9 11:34:28 srv11 kernel: [ 1081.334970] ------------[ cut here ]---=
---------
Jan  9 11:34:28 srv11 kernel: [ 1081.353685] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:34:28 srv11 kernel: [ 1081.371956] Hardware name: System x369=
0 X5 -[7148Z68]-
Jan  9 11:34:28 srv11 kernel: [ 1081.391820] cleanup rbuf bug: copied A=
D3BCF1 seq AD370AF rcvnxt AD3CF13
Jan  9 11:34:28 srv11 kernel: [ 1081.408971] Modules linked in: 8021q g=
arp stp llc nls_utf8 nls_cp437 vfat fat kvm_intel coretemp kvm joydev a=
cpi_cpufreq mperf crc32c_intel hid_generic shpchp snd_pcm snd_timer snd=
 lpc_ich mfd_core cdc_ether usb
net mii evdev serio_raw ioatdma processor i2c_i801 tpm_tis dca soundcor=
e snd_page_alloc pcspkr tpm microcode i2c_core tpm_bios thermal_sys but=
ton pci_hotplug ext4 mbcache jbd2 crc16 dm_mod sg sr_mod cdrom sd_mod c=
rc_t10dif usbhid ata_generic hi
d uhci_hcd ata_piix libata megaraid_sas bnx2 ehci_hcd usbcore scsi_mod =
usb_common be2net
Jan  9 11:34:28 srv11 kernel: [ 1081.532314] Pid: 13763, comm: haproxy =
Not tainted 3.7.1 #1
Jan  9 11:34:28 srv11 kernel: [ 1081.554349] Call Trace:
Jan  9 11:34:28 srv11 kernel: [ 1081.573762]  [<ffffffff8103ef70>] ? wa=
rn_slowpath_common+0x78/0x8c
Jan  9 11:34:28 srv11 kernel: [ 1081.596750]  [<ffffffff8103f023>] ? wa=
rn_slowpath_fmt+0x45/0x4a
Jan  9 11:34:28 srv11 kernel: [ 1081.617853]  [<ffffffff81297d06>] ? so=
ck_pipe_buf_release+0xe/0xe
Jan  9 11:34:28 srv11 kernel: [ 1081.639111]  [<ffffffff812d37c2>] ? tc=
p_cleanup_rbuf+0x4d/0xfc
Jan  9 11:34:28 srv11 kernel: [ 1081.661541]  [<ffffffff812d39f4>] ? tc=
p_read_sock+0x183/0x194
Jan  9 11:34:28 srv11 kernel: [ 1081.681164]  [<ffffffff812d423d>] ? tc=
p_sendpage+0x45b/0x45b
Jan  9 11:34:28 srv11 kernel: [ 1081.703355]  [<ffffffff812d3ad8>] ? tc=
p_splice_read+0xd3/0x223
Jan  9 11:34:28 srv11 kernel: [ 1081.724912]  [<ffffffff8112d9b9>] ? sy=
s_splice+0x345/0x3c0
Jan  9 11:34:28 srv11 kernel: [ 1081.744525]  [<ffffffff81364b69>] ? sy=
stem_call_fastpath+0x16/0x1b
Jan  9 11:34:28 srv11 kernel: [ 1081.766683] ---[ end trace fb4ffd749d5=
1e56f ]---

Jan  9 11:52:42 srv11 kernel: [ 2174.882971] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:42 srv11 kernel: [ 2174.901182] Hardware name: System x369=
0 X5 -[7148Z68]-
Jan  9 11:52:42 srv11 kernel: [ 2174.921229] recvmsg bug 2: copied 4B9C=
4CE6 seq 4B9BE950 rcvnxt 4B9C4CE6 fl 0
Jan  9 11:52:42 srv11 kernel: [ 2174.941681] Modules linked in: 8021q g=
arp stp llc nls_utf8 nls_cp437 vfat fat kvm_intel coretemp kvm joydev a=
cpi_cpufreq mperf crc32c_intel hid_generic shpchp snd_pcm snd_timer snd=
 lpc_ich mfd_core cdc_ether usb
net mii evdev serio_raw ioatdma processor i2c_i801 tpm_tis dca soundcor=
e snd_page_alloc pcspkr tpm microcode i2c_core tpm_bios thermal_sys but=
ton pci_hotplug ext4 mbcache jbd2 crc16 dm_mod sg sr_mod cdrom sd_mod c=
rc_t10dif usbhid ata_generic hi
d uhci_hcd ata_piix libata megaraid_sas bnx2 ehci_hcd usbcore scsi_mod =
usb_common be2net
Jan  9 11:52:42 srv11 kernel: [ 2175.075389] Pid: 13250, comm: haproxy =
Tainted: G        W    3.7.1 #1
Jan  9 11:52:42 srv11 kernel: [ 2175.099391] Call Trace:
Jan  9 11:52:42 srv11 kernel: [ 2175.122727]  [<ffffffff8103ef70>] ? wa=
rn_slowpath_common+0x78/0x8c
Jan  9 11:52:42 srv11 kernel: [ 2175.147250]  [<ffffffff8103f023>] ? wa=
rn_slowpath_fmt+0x45/0x4a
Jan  9 11:52:42 srv11 kernel: [ 2175.170289]  [<ffffffff81295f64>] ? re=
lease_sock+0xe6/0x11c
Jan  9 11:52:43 srv11 kernel: [ 2175.192639]  [<ffffffff812d45d2>] ? tc=
p_recvmsg+0x2ca/0x9de
Jan  9 11:52:43 srv11 kernel: [ 2175.215020]  [<ffffffff812e0b71>] ? tc=
p_write_xmit+0x849/0x946
Jan  9 11:52:43 srv11 kernel: [ 2175.237682]  [<ffffffff812f2720>] ? in=
et_recvmsg+0x64/0x75
Jan  9 11:52:43 srv11 kernel: [ 2175.259727]  [<ffffffff8129052d>] ? so=
ck_recvmsg+0x56/0x6e
Jan  9 11:52:43 srv11 kernel: [ 2175.281111]  [<ffffffff8128fedf>] ? so=
ckfd_lookup_light+0x1a/0x50
Jan  9 11:52:43 srv11 kernel: [ 2175.300573]  [<ffffffff812923f4>] ? sy=
s_recvfrom+0xbf/0x120
Jan  9 11:52:43 srv11 kernel: [ 2175.320073]  [<ffffffff8135d9f7>] ? __=
schedule+0x4c9/0x4f6
Jan  9 11:52:43 srv11 kernel: [ 2175.341151]  [<ffffffff81364b69>] ? sy=
stem_call_fastpath+0x16/0x1b
Jan  9 11:52:43 srv11 kernel: [ 2175.360859] ---[ end trace fb4ffd749d5=
1e5a7 ]---

As you can see here, the messages are appearing every couple of minutes=
:

Jan  9 11:34:28 srv11 kernel: [ 1081.353685] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:34:29 srv11 kernel: [ 1081.809446] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:34:29 srv11 kernel: [ 1082.235052] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:29 srv11 kernel: [ 1082.692732] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:30 srv11 kernel: [ 1083.177807] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:30 srv11 kernel: [ 1083.698475] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:31 srv11 kernel: [ 1084.221899] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:31 srv11 kernel: [ 1084.746992] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:34:32 srv11 kernel: [ 1085.267199] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:16 srv11 kernel: [ 1249.252200] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:17 srv11 kernel: [ 1249.782915] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:17 srv11 kernel: [ 1250.315653] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:18 srv11 kernel: [ 1250.867306] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:18 srv11 kernel: [ 1251.383968] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:19 srv11 kernel: [ 1251.897631] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:19 srv11 kernel: [ 1252.412535] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:37:20 srv11 kernel: [ 1252.921313] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:13 srv11 kernel: [ 1425.644620] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:13 srv11 kernel: [ 1426.314292] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:14 srv11 kernel: [ 1426.749374] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:14 srv11 kernel: [ 1427.198672] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:15 srv11 kernel: [ 1427.711731] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:40:15 srv11 kernel: [ 1428.189284] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:40:16 srv11 kernel: [ 1428.701230] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:09 srv11 kernel: [ 1781.780019] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:09 srv11 kernel: [ 1782.350094] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:10 srv11 kernel: [ 1782.853933] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:10 srv11 kernel: [ 1783.303487] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:11 srv11 kernel: [ 1783.757022] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:11 srv11 kernel: [ 1784.260932] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:12 srv11 kernel: [ 1784.874611] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:13 srv11 kernel: [ 1785.457209] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:13 srv11 kernel: [ 1785.933210] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:14 srv11 kernel: [ 1786.400550] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:14 srv11 kernel: [ 1786.941620] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:15 srv11 kernel: [ 1787.510305] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:15 srv11 kernel: [ 1788.077590] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:54 srv11 kernel: [ 1827.316572] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:55 srv11 kernel: [ 1827.721460] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:55 srv11 kernel: [ 1828.150593] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:56 srv11 kernel: [ 1828.620180] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:56 srv11 kernel: [ 1829.120693] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:46:57 srv11 kernel: [ 1829.597494] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:57 srv11 kernel: [ 1830.189551] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:58 srv11 kernel: [ 1830.745157] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:58 srv11 kernel: [ 1831.299635] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:46:59 srv11 kernel: [ 1831.852929] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:47:00 srv11 kernel: [ 1832.408950] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:52:38 srv11 kernel: [ 2170.882305] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:52:39 srv11 kernel: [ 2171.342827] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:39 srv11 kernel: [ 2171.853599] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:40 srv11 kernel: [ 2172.355757] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:40 srv11 kernel: [ 2172.856194] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:41 srv11 kernel: [ 2173.357738] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:41 srv11 kernel: [ 2173.857774] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:42 srv11 kernel: [ 2174.361131] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()
Jan  9 11:52:42 srv11 kernel: [ 2174.882971] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:43 srv11 kernel: [ 2175.397627] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:43 srv11 kernel: [ 2175.911679] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:44 srv11 kernel: [ 2176.424397] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:44 srv11 kernel: [ 2176.940545] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:45 srv11 kernel: [ 2177.456173] WARNING: at net/ipv4/tcp.c=
:1639 tcp_recvmsg+0x2ca/0x9de()
Jan  9 11:52:45 srv11 kernel: [ 2177.971222] WARNING: at net/ipv4/tcp.c=
:1330 tcp_cleanup_rbuf+0x4d/0xfc()