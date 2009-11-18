From: Ben Hutchings <ben@decadent.org.uk>
Subject: nf_conntrack sets wrong value for ctorigsrc parameter
Date: Wed, 18 Nov 2009 07:39:18 +0000
Message-ID: <1258529958.2810.36.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VxYdEeDHZA7u2gnzmKQO"
Cc: Michel Messerschmidt <lists@michel-messerschmidt.de>,
	556587@bugs.debian.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56053 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbZKRHjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 02:39:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VxYdEeDHZA7u2gnzmKQO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

=46rom the Debian bug tracking system:

-------- Forwarded Message --------
From: Michel Messerschmidt <lists@michel-messerschmidt.de>
Reply-to: Michel Messerschmidt <lists@michel-messerschmidt.de>, 556587@bugs=
.debian.org
To: Debian Bug Tracking System <submit@bugs.debian.org>
Subject: Bug#556587: linux-image-2.6.31-1-686-bigmem: nf_conntrack sets wro=
ng value for ctorigsrc parameter
Date: Mon, 16 Nov 2009 23:09:10 +0100

Package: linux-2.6
Version: 2.6.31-2
Severity: normal

My iptables script using the conntrack module does not work with this kerne=
l=20
version anymore. The value of the ctorigsrc parameter is not set correctly:
rei:~$ cat /etc/mm_iptables/mm_iptables_dmz | grep -E 'ctorig|LOCALIP=3D'
LOCALIP=3D"192.168.40.3"
        $IPT -A in_dmz -p udp --dport 1024:65535 -m conntrack --ctproto udp=
 --ctorigsrc $LOCALIP --ctorigdstport 53 --ctreplsrcport 53 -j ACCEPT
        $IPT -A in_dmz -p udp --dport 1024:65535 -m conntrack --ctstate REL=
ATED,ESTABLISHED --ctproto udp --ctorigsrc $LOCALIP -j ACCEPT
rei:~$ iptables -nvL | grep ctorig
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0=
/0           udp dpts:1024:65535 ctproto 17 ctorigsrc 192.60.154.245 ctorig=
dstport 53 ctreplsrcport 53=20
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0=
/0           udp dpts:1024:65535 ctstate RELATED,ESTABLISHED ctproto 17 cto=
rigsrc 128.49.154.245=20

I see the same behavior with the 686 flavour (without bigmem).

With older kernels up to 2.6.30-8, the ctorigsrc value was set as expected:
rei:~$ iptables -nvL | grep ctorig
   21  2452 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0=
/0           udp dpts:1024:65535 ctproto 17 ctorigsrc 192.168.40.3 ctorigds=
tport 53 ctreplsrcport 53=20
    0     0 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0=
/0           udp dpts:1024:65535 ctstate RELATED,ESTABLISHED ctproto 17 cto=
rigsrc 192.168.40.3=20



-- Package-specific info:
** Version:
Linux version 2.6.31-1-686-bigmem (Debian 2.6.31-2) (ben@decadent.org.uk) (=
gcc version 4.3.4 (Debian 4.3.4-6) ) #1 SMP Sun Nov 15 21:22:56 UTC 2009

** Command line:
BOOT_IMAGE=3D/vmlinuz-2.6.31-1-686-bigmem root=3D/dev/mapper/sda2_crypt ro =
vdso=3D1

** Not tainted

** Kernel log:
[  252.421890] FW-DROP-DEFAULT IN=3Deth1 OUT=3D MAC=3D00:08:54:50:08:d8:00:=
16:38:aa:fd:00:08:00 SRC=3D217.237.150.205 DST=3D192.168.40.3 LEN=3D126 TOS=
=3D0x00 PREC=3D0x00 TTL=3D60 ID=3D0 DF PROTO=3DUDP SPT=3D53 DPT=3D25586 LEN=
=3D106=20
[  252.425260] FW-DROP-DEFAULT IN=3Deth1 OUT=3D MAC=3D00:08:54:50:08:d8:00:=
16:38:aa:fd:00:08:00 SRC=3D217.237.149.142 DST=3D192.168.40.3 LEN=3D126 TOS=
=3D0x00 PREC=3D0x00 TTL=3D59 ID=3D0 DF PROTO=3DUDP SPT=3D53 DPT=3D25586 LEN=
=3D106=20
[  252.425929] FW-DROP-DEFAULT IN=3Deth1 OUT=3D MAC=3D00:08:54:50:08:d8:00:=
16:38:aa:fd:00:08:00 SRC=3D217.237.150.205 DST=3D192.168.40.3 LEN=3D144 TOS=
=3D0x00 PREC=3D0x00 TTL=3D60 ID=3D0 DF PROTO=3DUDP SPT=3D53 DPT=3D42698 LEN=
=3D124=20
[  252.429781] FW-DROP-DEFAULT IN=3Deth1 OUT=3D MAC=3D00:08:54:50:08:d8:00:=
16:38:aa:fd:00:08:00 SRC=3D217.237.149.142 DST=3D192.168.40.3 LEN=3D144 TOS=
=3D0x00 PREC=3D0x00 TTL=3D59 ID=3D0 DF PROTO=3DUDP SPT=3D53 DPT=3D42698 LEN=
=3D124=20
[...cut many repeated log messages...]

** Model information
not available

** Loaded modules:
Module                  Size  Used by
tun                    13120  2=20
video                  19856  0=20
output                  2872  1 video
ac                      3124  0=20
battery                 6348  0=20
acpi_cpufreq            8104  0=20
cpufreq_userspace       2944  0=20
cpufreq_conservative     6780  0=20
cpufreq_powersave       1408  0=20
cpufreq_stats           3868  0=20
nfsd                  223620  9=20
exportfs                4016  1 nfsd
nfs                   252000  0=20
lockd                  64696  2 nfsd,nfs
fscache                36696  1 nfs
nfs_acl                 2860  2 nfsd,nfs
auth_rpcgss            34388  2 nfsd,nfs
sunrpc                181096  10 nfsd,nfs,lockd,nfs_acl,auth_rpcgss
ipt_MASQUERADE          2400  1=20
iptable_nat             5596  1=20
xt_TCPMSS               3604  1=20
xt_conntrack            4028  36=20
xt_tcpudp               2716  195=20
ip6t_LOG                4864  1=20
ipt_LOG                 4784  39=20
ip6table_filter         3312  1=20
ip6_tables             12000  2 ip6t_LOG,ip6table_filter
iptable_filter          3240  1=20
nf_nat                 17316  2 ipt_MASQUERADE,iptable_nat
nf_conntrack_ftp        6592  0=20
nf_conntrack_ipv4      13120  39 iptable_nat,nf_nat
nf_conntrack           64156  6 ipt_MASQUERADE,iptable_nat,xt_conntrack,nf_=
nat,nf_conntrack_ftp,nf_conntrack_ipv4
nf_defrag_ipv4          1808  1 nf_conntrack_ipv4
ip_tables              10764  2 iptable_nat,iptable_filter
x_tables               16084  9 ipt_MASQUERADE,iptable_nat,xt_TCPMSS,xt_con=
ntrack,xt_tcpudp,ip6t_LOG,ipt_LOG,ip6_tables,ip_tables
fuse                   58196  1=20
ext2                   58996  1=20
hwmon_vid               2576  0=20
eeprom                  5184  0=20
firewire_sbp2          14016  0=20
loop                   14268  0=20
snd_ca0106             32032  0=20
snd_rawmidi            20452  1 snd_ca0106
snd_seq_device          6780  1 snd_rawmidi
snd_ac97_codec         99668  1 snd_ca0106
snd_pcsp                9540  0=20
ac97_bus                1628  1 snd_ac97_codec
i2c_i801                8952  0=20
snd_pcm                70136  3 snd_ca0106,snd_ac97_codec,snd_pcsp
snd_timer              19000  1 snd_pcm
i2c_core               21744  2 eeprom,i2c_i801
rng_core                3996  0=20
snd                    54440  7 snd_ca0106,snd_rawmidi,snd_seq_device,snd_a=
c97_codec,snd_pcsp,snd_pcm,snd_timer
soundcore               6844  1 snd
snd_page_alloc          8716  2 snd_ca0106,snd_pcm
evdev                   8832  3=20
button                  5488  0=20
processor              36772  1 acpi_cpufreq
ext4                  284896  8=20
mbcache                 7488  2 ext2,ext4
jbd2                   73892  1 ext4
crc16                   1840  1 ext4
cbc                     3352  9=20
dm_crypt               12340  9=20
dm_mod                 65432  40 dm_crypt
sd_mod                 31840  7=20
crc_t10dif              1716  1 sd_mod
ide_pci_generic         3784  0=20
ide_core               97736  1 ide_pci_generic
ata_generic             4500  0=20
ahci                   33412  0=20
ata_piix               21532  5=20
uhci_hcd               20568  0=20
libata                163228  3 ata_generic,ahci,ata_piix
firewire_ohci          20740  0=20
firewire_core          45276  2 firewire_sbp2,firewire_ohci
crc_itu_t               1892  1 firewire_core
r8169                  30624  0=20
mii                     5048  1 r8169
ehci_hcd               32868  0=20
scsi_mod              143036  3 firewire_sbp2,sd_mod,libata
tg3                    97292  0=20
libphy                 23160  1 tg3
usbcore               141496  4 uhci_hcd,ehci_hcd
nls_base                7188  1 usbcore
intel_agp              25752  1=20
agpgart                33112  1 intel_agp
thermal                13720  0=20
fan                     4460  0=20
thermal_sys            14396  4 video,processor,thermal,fan
aes_i586                8312  18=20
aes_generic            27640  1 aes_i586
sha256_generic         11492  0=20

** Network interface configuration:
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback
	post-up /etc/mm_iptables/mm_iptables_init start

# The primary network interface
# really use hotplug ???
#allow-hotplug eth0
auto eth0
iface eth0 inet static
	address 192.168.42.3
	netmask 255.255.255.0
	broadcast 192.168.42.255
	# gateway must not be set here to allow dialup connections
	#gateway 192.168.42.3
	# hardware address (MAC)
#	hwaddress ether=20
	# set MTU for ethernet only network
	mtu 1500
	# dns-* options are implemented by the resolvconf package, if installed
	dns-nameservers 192.168.42.3
	dns-search matrix
	# handle firewall rules for this interface
	post-up /etc/mm_iptables/mm_iptables_localnet start
	pre-down /etc/mm_iptables/mm_iptables_localnet stop || true

auto eth1
iface eth1 inet static
	address 192.168.40.3
	netmask 255.255.255.0
	broadcast 192.168.40.255
	# gateway must not be set here to allow dialup connections
	gateway 192.168.40.1
	# hardware address (MAC)
#	hwaddress ether=20
	# set MTU for dialup / dsl / internet
	mtu 1492
	# dns-* options are implemented by the resolvconf package, if installed
	dns-nameservers 192.168.42.3
	dns-search home
	# handle firewall rules for this interface
	post-up /etc/mm_iptables/mm_iptables_dmz start
	pre-down /etc/mm_iptables/mm_iptables_dmz stop || true


** Network status:
*** IP interfaces and addresses:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
2: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast state =
UNKNOWN qlen 1000
    link/ether 00:08:54:50:08:d8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.40.3/24 brd 192.168.40.255 scope global eth1
    inet6 fe80::208:54ff:fe50:8d8/64 scope link=20
       valid_lft forever preferred_lft forever
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state =
UP qlen 1000
    link/ether 00:30:1b:ba:73:70 brd ff:ff:ff:ff:ff:ff
    inet 192.168.42.3/24 brd 192.168.42.255 scope global eth0
    inet6 fe80::230:1bff:feba:7370/64 scope link=20
       valid_lft forever preferred_lft forever
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fas=
t state UNKNOWN qlen 100
    link/[65534]=20
    inet 10.1.41.3 peer 10.1.41.10/32 scope global tun0

*** Device statistics:
Inter-|   Receive                                                |  Transmi=
t
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    =
packets errs drop fifo colls carrier compressed
    lo:   18976     258    0    0    0     0          0         0    18976 =
    258    0    0    0     0       0          0
  eth1:   48518     332    0    0    0     0          0         0    30390 =
    378    0    0    0     0       0          0
  eth0:   84454     855    0    0    0     0          0         0   115085 =
    537    0    0    0     0       0          0
  tun0:       0       0    0    0    0     0          0         0        0 =
      0    0    0    0     0       0          0

*** Protocol statistics:
Ip:
    1475 total packets received
    70 forwarded
    0 incoming packets discarded
    1105 incoming packets delivered
    1146 requests sent out
Icmp:
    1 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 1
    1 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 1
IcmpMsg:
        InType3: 1
        OutType3: 1
Tcp:
    4 active connections openings
    2 passive connection openings
    4 failed connection attempts
    0 connection resets received
    2 connections established
    727 segments received
    452 segments send out
    0 segments retransmited
    0 bad segments received.
    9 resets sent
Udp:
    377 packets received
    1 packets to unknown port received.
    0 packet receive errors
    627 packets sent
UdpLite:
TcpExt:
    4 delayed acks sent
    4 packets directly queued to recvmsg prequeue.
    230 packet headers predicted
    45 acknowledgments not containing data payload received
    376 predicted acknowledgments
IpExt:
    InBcastPkts: 48
    OutBcastPkts: 48
    InOctets: 136879
    OutOctets: 148461
    InBcastOctets: 5833
    OutBcastOctets: 5833

*** Device features:
eth0: 0x109a3
eth1: 0x180
lo: 0x13865
tun0: 0x0

** PCI devices:
00:00.0 Host bridge [0600]: Intel Corporation Mobile 915GM/PM/GMS/910GML Ex=
press Processor to DRAM Controller [8086:2590] (rev 04)
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller [0300]: Intel Corporation Mobile 915GM/GM=
S/910GML Express Graphics Controller [8086:2592] (rev 04) (prog-if 00 [VGA =
controller])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 5
	Region 0: Memory at dff00000 (32-bit, non-prefetchable) [size=3D512K]
	Region 1: I/O ports at ff00 [size=3D8]
	Region 2: Memory at c0000000 (32-bit, prefetchable) [size=3D256M]
	Region 3: Memory at dff80000 (32-bit, non-prefetchable) [size=3D256K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: <access denied>

00:02.1 Display controller [0380]: Intel Corporation Mobile 915GM/GMS/910GM=
L Express Graphics Controller [8086:2792] (rev 04)
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Region 0: Memory at dfe80000 (32-bit, non-prefetchable) [disabled] [size=
=3D512K]
	Capabilities: <access denied>

00:1c.0 PCI bridge [0604]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Fa=
mily) PCI Express Port 1 [8086:2660] (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: dfd00000-dfdfffff
	Prefetchable memory behind bridge: 00000000dfa00000-00000000dfafffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport-driver

00:1c.2 PCI bridge [0604]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Fa=
mily) PCI Express Port 3 [8086:2664] (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
	I/O behind bridge: 0000b000-0000bfff
	Memory behind bridge: df900000-df9fffff
	Prefetchable memory behind bridge: 00000000df800000-00000000df8fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport-driver

00:1d.0 USB Controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #1 [8086:2658] (rev 04) (prog-if 00 [UHCI])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at fe00 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #2 [8086:2659] (rev 04) (prog-if 00 [UHCI])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at fd00 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #3 [8086:265a] (rev 04) (prog-if 00 [UHCI])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at fc00 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB Controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #4 [8086:265b] (rev 04) (prog-if 00 [UHCI])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at fb00 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB2 EHCI Controller [8086:265c] (rev 04) (prog-if 20 [EHCI])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at dffff000 (32-bit, non-prefetchable) [size=3D1K]
	Capabilities: <access denied>
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge [0604]: Intel Corporation 82801 Mobile PCI Bridge [8086:=
2448] (rev d4) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D32
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: dfc00000-dfcfffff
	Prefetchable memory behind bridge: 00000000dfb00000-00000000dfbfffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:1f.0 ISA bridge [0601]: Intel Corporation 82801FBM (ICH6M) LPC Interface=
 Bridge [8086:2641] (rev 04)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:1f.2 IDE interface [0101]: Intel Corporation 82801FBM (ICH6M) SATA Contr=
oller [8086:2653] (rev 04) (prog-if 80 [Master])
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 0: I/O ports at 01f0 [size=3D8]
	Region 1: I/O ports at 03f4 [size=3D1]
	Region 2: I/O ports at 0170 [size=3D8]
	Region 3: I/O ports at 0374 [size=3D1]
	Region 4: I/O ports at f800 [size=3D16]
	Capabilities: <access denied>
	Kernel driver in use: ata_piix

00:1f.3 SMBus [0c05]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)=
 SMBus Controller [8086:266a] (rev 04)
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 0500 [size=3D32]
	Kernel driver in use: i801_smbus

01:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink BCM5789 Gi=
gabit Ethernet PCI Express [14e4:169d] (rev 11)
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:fd11]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at dfdf0000 (64-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: <access denied>
	Kernel driver in use: tg3

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111=
/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev 01)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigab=
it Ethernet controller [10ec:8168]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 26
	Region 0: I/O ports at be00 [size=3D256]
	Region 2: Memory at df9ff000 (64-bit, non-prefetchable) [size=3D4K]
	[virtual] Expansion ROM at df800000 [disabled] [size=3D128K]
	Capabilities: <access denied>
	Kernel driver in use: r8169

03:09.0 Multimedia audio controller [0401]: Creative Labs CA0106 Soundblast=
er [1102:0007]
	Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device [1297:3041]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (500ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 17
	Region 0: I/O ports at df00 [size=3D32]
	Capabilities: <access denied>
	Kernel driver in use: CA0106

03:0a.0 FireWire (IEEE 1394) [0c00]: VIA Technologies, Inc. VT6306 Fire II =
IEEE 1394 OHCI Link Layer Controller [1106:3044] (rev 80) (prog-if 10 [OHCI=
])
	Subsystem: VIA Technologies, Inc. VT6306 Fire II IEEE 1394 OHCI Link Layer=
 Controller [1106:3044]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng+ SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (8000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at dfcff000 (32-bit, non-prefetchable) [size=3D2K]
	Region 1: I/O ports at de00 [size=3D128]
	Capabilities: <access denied>
	Kernel driver in use: firewire_ohci


** USB devices:
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 005 Device 002: ID 04e6:5115 SCM Microsystems, Inc. SCR335 SmartCard Re=
ader
Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub


-- System Information:
Debian Release: squeeze/sid
  APT prefers testing
  APT policy: (990, 'testing'), (500, 'unstable'), (500, 'stable'), (1, 'ex=
perimental')
Architecture: i386 (i686)

Kernel: Linux 2.6.31-1-686-bigmem (SMP w/1 CPU core)
Locale: LANG=3Dde_DE.UTF-8, LC_CTYPE=3Dde_DE.UTF-8 (charmap=3DUTF-8)
Shell: /bin/sh linked to /bin/bash

Versions of packages linux-image-2.6.31-1-686-bigmem depends on:
ii  debconf [debconf-2.0]         1.5.28     Debian configuration managemen=
t sy
ii  initramfs-tools [linux-initra 0.93.4     tools for generating an initra=
mfs
ii  module-init-tools             3.11-1     tools for managing Linux kerne=
l mo

Versions of packages linux-image-2.6.31-1-686-bigmem recommends:
ii  firmware-linux-free           2.6.31-2   Binary firmware for various dr=
iver
ii  libc6-i686                    2.10.1-7   GNU C Library: Shared librarie=
s [i

Versions of packages linux-image-2.6.31-1-686-bigmem suggests:
ii  grub                          0.97-59    GRand Unified Bootloader (dumm=
y pa
pn  linux-doc-2.6.31              <none>     (no description available)

Versions of packages linux-image-2.6.31-1-686-bigmem is related to:
pn  firmware-bnx2                 <none>     (no description available)
pn  firmware-bnx2x                <none>     (no description available)
pn  firmware-ipw2x00              <none>     (no description available)
pn  firmware-ivtv                 <none>     (no description available)
pn  firmware-iwlwifi              <none>     (no description available)
ii  firmware-linux                0.18       Binary firmware for various dr=
iver
pn  firmware-linux-nonfree        <none>     (no description available)
pn  firmware-qlogic               <none>     (no description available)
pn  firmware-ralink               <none>     (no description available)

-- debconf information:
  shared/kernel-image/really-run-bootloader: true
  linux-image-2.6.31-1-686-bigmem/postinst/bootloader-error-2.6.31-1-686-bi=
gmem:
  linux-image-2.6.31-1-686-bigmem/postinst/depmod-error-initrd-2.6.31-1-686=
-bigmem: false
  linux-image-2.6.31-1-686-bigmem/prerm/removing-running-kernel-2.6.31-1-68=
6-bigmem: true
  linux-image-2.6.31-1-686-bigmem/postinst/bootloader-test-error-2.6.31-1-6=
86-bigmem:
  linux-image-2.6.31-1-686-bigmem/postinst/missing-firmware-2.6.31-1-686-bi=
gmem:
  linux-image-2.6.31-1-686-bigmem/prerm/would-invalidate-boot-loader-2.6.31=
-1-686-bigmem: true


-- System Information:
Debian Release: squeeze/sid
  APT prefers testing
  APT policy: (990, 'testing'), (500, 'unstable'), (500, 'stable'), (1, 'ex=
perimental')
Architecture: i386 (i686)

Kernel: Linux 2.6.30-2-686 (SMP w/1 CPU core)
Locale: LANG=3Dde_DE.UTF-8, LC_CTYPE=3Dde_DE.UTF-8 (charmap=3DUTF-8)
Shell: /bin/sh linked to /bin/bash

Versions of packages linux-image-2.6.31-1-686-bigmem depends on:
ii  debconf [debconf-2.0]         1.5.28     Debian configuration managemen=
t sy
ii  initramfs-tools [linux-initra 0.93.4     tools for generating an initra=
mfs
ii  module-init-tools             3.11-1     tools for managing Linux kerne=
l mo

Versions of packages linux-image-2.6.31-1-686-bigmem recommends:
ii  firmware-linux-free           2.6.31-2   Binary firmware for various dr=
iver
ii  libc6-i686                    2.10.1-7   GNU C Library: Shared librarie=
s [i

Versions of packages linux-image-2.6.31-1-686-bigmem suggests:
ii  grub                          0.97-59    GRand Unified Bootloader (dumm=
y pa
pn  linux-doc-2.6.31              <none>     (no description available)

Versions of packages linux-image-2.6.31-1-686-bigmem is related to:
pn  firmware-bnx2                 <none>     (no description available)
pn  firmware-bnx2x                <none>     (no description available)
pn  firmware-ipw2x00              <none>     (no description available)
pn  firmware-ivtv                 <none>     (no description available)
pn  firmware-iwlwifi              <none>     (no description available)
ii  firmware-linux                0.18       Binary firmware for various dr=
iver
pn  firmware-linux-nonfree        <none>     (no description available)
pn  firmware-qlogic               <none>     (no description available)
pn  firmware-ralink               <none>     (no description available)



--=-VxYdEeDHZA7u2gnzmKQO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASwOkoOe/yOyVhhEJAQLDNQ//aVlSwuDqZS+eSMldG4SYuf3O8H7OaLrc
ffNuU5htpnJKxlADahgMh2w2TOMUgUf4hZ9KrZN9/3Aztbmis0/jd1BwGu3fvK4v
cvinSJnj7wS6y3orVTgU+84Nf7DPOxbQJcUlZU3CbMil2kbu9INkn4hOOB7Gjxlz
La0eXGcE7rJXTxQvjoKQDpn8lWOYhe9xkgrCJ5m/eTuLtBTvPOSVecIwdflst32k
5CTUF4utb5l+TU5FyZ4WofTdkIaDntmgLulcvQR2JA8imeUTbsC+DpOaKOcVNdp+
SWRd36jo7xmBSAeGEbqJ8Fli9n6dy0eDKcQrV5h6ytUUk9rlEioKdw1ZedI7x2E2
M6Og/3UjtRQZnoGDNJigyEuOymxztcVR5Pp8G/fD1HL8J/08cjo0ZSXyvEHERzvS
vMniAhazU7k5PQWCBCCrsw3jOdzEwiFxE/hkAp8YWsdaKw/gL6bMZVue++r/EHfT
rh4wZVTT75RBs2GwFNNohwfvlYZUE3gx6o1PF/4Q/ug2WnVR1qsODmRSoBsmFCxe
nK0XZvRkGEHc8F8K4j93vpvo2NN2GrN1B05eAFb3yo9wZpdhmvKkmtmOSvQfL6mD
4C4Ls7Ve3xWiuzWk4VEvqHoMnxghF7hiweFIz5PkU60npSuqdg2YcbBcye8FF16f
6f3d3kjsvo4=
=GZhS
-----END PGP SIGNATURE-----

--=-VxYdEeDHZA7u2gnzmKQO--
