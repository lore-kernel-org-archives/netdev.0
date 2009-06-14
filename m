From: Sven Brauch <svenbrauch@googlemail.com>
Subject: Fwd: Bug-report for the rt2500pci module
Date: Sun, 14 Jun 2009 10:55:16 +0000
Message-ID: <200906141055.16884.svenbrauch@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:2692 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbZFNIwC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 04:52:02 -0400
Received: by fg-out-1718.google.com with SMTP id 16so917542fgg.17
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 01:52:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I experience some problems using the kernel-built-in module "rt2500pci"=
 as a
driver for my RaLink RT2500 802.11g PCI-network card. I do *not*, with =
the
same hardware and software configuration, have these problems if I use =
the
module "rt2500" from serialmonkey.com. In the ##kernel channel on
irc.freenode.net, I have been told to write you an email about this.

The problems are:
a. Connection instability. Especially if the network quality is low, th=
e
connection is very unstable. I experience this as random disconnects (c=
ould
be after 10 mins, or 2 hours, completely random), and as having problem=
s to
establish a connection using DHCP (fails getting an IP adress). There i=
s a
correlation between my ESSID being displayed in "iwlist scan" network l=
ist
and the connection to be working, but the ESSID being found does not
necessarily mean I will be able to connect. If the connection fails, it=
 is
very very hard to re-establish it; loading and unloading the rt2500pci
module several times sometimes solves the problem. It doesn't matter we=
ather
I use dhclient, dhcpcd, or NetworkManager (don't know which
DHCP-implementation NetworkManager uses).
b. Low bandwidth (limited to 1 MBit/s). This problem is probably fixed =
with
the newest release in the .29 kernel (at least, I didn't have problems =
with
that so far).

I don't exactly know what information could be useful for you, so here =
just
some things of which I think they could be useful (please write if you =
need
more):
lspci
--snip--
00:00.0 Host bridge: VIA Technologies, Inc. PT880 Ultra/PT894 Host Brid=
ge
00:00.1 Host bridge: VIA Technologies, Inc. PT894 Host Bridge
00:00.2 Host bridge: VIA Technologies, Inc. PT894 Host Bridge
00:00.3 Host bridge: VIA Technologies, Inc. PT890 Host Bridge
00:00.4 Host bridge: VIA Technologies, Inc. PT894 Host Bridge
00:00.5 PIC: VIA Technologies, Inc. PT894 I/O APIC Interrupt Controller
00:00.7 Host bridge: VIA Technologies, Inc. PT894 Host Bridge
00:01.0 PCI bridge: VIA Technologies, Inc. VT8237/VX700 PCI Bridge
00:02.0 PCI bridge: VIA Technologies, Inc. PT890 PCI to PCI Bridge
Controller
00:0b.0 Network controller: RaLink RT2500 802.11g Cardbus/mini-PCI (rev=
 01)
00:0f.0 IDE interface: VIA Technologies, Inc. VT8237A SATA 2-Port Contr=
oller
(rev 80)
00:0f.1 IDE interface: VIA Technologies, Inc.
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 07)
00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev a0)
00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev a0)
00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev a0)
00:10.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev a0)
00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 86)
00:11.0 ISA bridge: VIA Technologies, Inc. VT8237A PCI to ISA Bridge
00:11.7 Host bridge: VIA Technologies, Inc. VT8251 Ultra VLINK Controll=
er
00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (=
rev
7c)
00:13.0 Host bridge: VIA Technologies, Inc. VT8237A Host Bridge
02:00.0 VGA compatible controller: nVidia Corporation G70 [GeForce 7600=
 GT]
(rev a1)
80:01.0 Audio device: VIA Technologies, Inc. VT1708/A [Azalia HDAC] (VI=
A
High Definition Audio Controller) (rev 10)
--snip--

lspci -n
--snip--
00:00.0 0600: 1106:0308
00:00.1 0600: 1106:1308
00:00.2 0600: 1106:2308
00:00.3 0600: 1106:3208
00:00.4 0600: 1106:4308
00:00.5 0800: 1106:5308
00:00.7 0600: 1106:7308
00:01.0 0604: 1106:b198
00:02.0 0604: 1106:a208
00:0b.0 0280: 1814:0201 (rev 01)
00:0f.0 0101: 1106:0591 (rev 80)
00:0f.1 0101: 1106:0571 (rev 07)
00:10.0 0c03: 1106:3038 (rev a0)
00:10.1 0c03: 1106:3038 (rev a0)
00:10.2 0c03: 1106:3038 (rev a0)
00:10.3 0c03: 1106:3038 (rev a0)
00:10.4 0c03: 1106:3104 (rev 86)
00:11.0 0601: 1106:3337
00:11.7 0600: 1106:287e
00:12.0 0200: 1106:3065 (rev 7c)
00:13.0 0600: 1106:337b
02:00.0 0300: 10de:0391 (rev a1)
80:01.0 0403: 1106:3288 (rev 10)
--snip--

uname -a (distribution: sabayon linux 4.1, but as mentioned before, I h=
ad
these problems with every version of the rt2500pci module since it is
included in the kernel, with very different distributions like SuSE, ge=
ntoo,
debian linux, ...
--snip--
Linux linuxbox 2.6.29-sabayon #1 SMP Fri Apr 24 08:21:15 UTC 2009 i686
Intel(R) Core(TM)2 CPU 6420 @ 2.13GHz GenuineIntel GNU/Linux
--snip--

iwconfig
--snip--
lo        no wireless extensions.

eth0      no wireless extensions.

wmaster0  no wireless extensions.

wlan0     IEEE 802.11bg  ESSID:"FRITZBox WLAN 3030"
          Mode:Managed  Frequency:2.417 GHz  Access Point: 00:15:0C:70:=
0A:07
          Bit Rate=3D11 Mb/s   Tx-Power=3D21 dBm
          Retry min limit:7   RTS thr:off   Fragment thr=3D2352 B
          Encryption key:****-****-****-****-****-****-**   Security
mode:open
          Power Management:off
          Link Quality=3D87/100  Signal level:-76 dBm
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0
--snip--

ifconfig
--snip--
eth0      Protokoll:Ethernet  Hardware Adresse 00:19:66:20:7d:36
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:23 Basisadresse:0xe800

lo        Protokoll:Lokale Schleife
          inet Adresse:127.0.0.1  Maske:255.0.0.0
          inet6 Adresse: ::1/128 G=FCltigkeitsbereich:Maschine
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:274 errors:0 dropped:0 overruns:0 frame:0
          TX packets:274 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:0
          RX bytes:20308 (19.8 KiB)  TX bytes:20308 (19.8 KiB)

wlan0     Protokoll:Ethernet  Hardware Adresse 00:80:5a:32:14:e7
          inet Adresse:192.168.178.25  Bcast:192.168.178.255
Maske:255.255.255.0
          inet6 Adresse: fe80::280:5aff:fe32:14e7/64
G=FCltigkeitsbereich:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1483 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1498 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:1163675 (1.1 MiB)  TX bytes:371887 (363.1 KiB)

wmaster0  Protokoll:UNSPEC  Hardware Adresse
00-80-5A-32-14-E7-77-6C-00-00-00-00-00-00-00-00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
--snip--

lsmod
--snip--
Module                  Size  Used by
snd_seq_midi            4336  0
snd_seq_dummy           1576  0
snd_seq_oss            23096  0
snd_seq_midi_event      4088  2 snd_seq_midi,snd_seq_oss
snd_seq                35148  6
snd_seq_midi,snd_seq_dummy,snd_seq_oss,snd_seq_midi_event
snd_pcm_oss            29192
0
snd_mixer_oss          10704  1
snd_pcm_oss
ipv6                  210728
26
rt2500pci              11544
0
snd_hda_codec_realtek   147056
1
snd_cs4232              8360
0
rt2x00pci               5420  1
rt2500pci
snd_hda_intel          17308
3
snd_wavefront          42620
0
snd_mpu401              4604
0
snd_hda_codec          43460  2
snd_hda_codec_realtek,snd_hda_intel
rt2x00lib              20932  2
rt2500pci,rt2x00pci
snd_wss_lib            17812  2
snd_cs4232,snd_wavefront
led_class               2532  1
rt2x00lib
snd_pcm                49408  4
snd_pcm_oss,snd_hda_intel,snd_hda_codec,snd_wss_lib
snd_opl3_lib            6868  2
snd_cs4232,snd_wavefront
snd_hwdep               5028  3
snd_wavefront,snd_hda_codec,snd_opl3_lib
snd_mpu401_uart         4408  3
snd_cs4232,snd_wavefront,snd_mpu401
snd_rawmidi            14372  3
snd_seq_midi,snd_wavefront,snd_mpu401_uart
mac80211              123340  2
rt2x00pci,rt2x00lib
snd_seq_device          4416  6
snd_seq_midi,snd_seq_dummy,snd_seq_oss,snd_seq,snd_opl3_lib,snd_rawmidi
irtty_sir               3188  0
snd_timer              13908  4 snd_seq,snd_wss_lib,snd_pcm,snd_opl3_li=
b
pcspkr                  1584  0
eeprom_93cx6            1276  1 rt2500pci
snd                    36748  24
snd_seq_oss,snd_seq,snd_pcm_oss,snd_mixer_oss,snd_hda_codec_realtek,snd=
_cs4232,snd_hda_intel,snd_wavefront,snd_mpu401,snd_hda_codec,snd_wss_li=
b,snd_pcm,snd_opl3_lib,snd_hwdep,snd_mpu401_uart,snd_rawmidi,snd_seq_de=
vice,snd_timer
sir_dev                 8588  1 irtty_sir
via_rhine              16116  0
nvidia               7219876  38
shpchp                 23776  0
ppdev                   5600  0
snd_page_alloc          6372  3 snd_hda_intel,snd_wss_lib,snd_pcm
parport_pc             22328  0
i2c_viapro              5284  0
pci_hotplug            19676  1 shpchp
i2c_core               14568  2 nvidia,i2c_viapro
via_agp                 5752  1
irda                   78740  1 sir_dev
crc_ccitt               1340  1 irda
parport                24296  2 ppdev,parport_pc
tg3                    94284  0
e1000                 103212  0
dm_bbr                  9296  0
sl811_hcd               9140  0
uhci_hcd               19060  0
ehci_hcd               30020  0
sx8                    13148  0
scsi_wait_scan          1004  0
b1                     20336  0
kernelcapi             28676  1 b1
--snip--

top -b (dunno if this is usefull)
--snip--
top - 00:25:21 up 12 min,  4 users,  load average: 0.19, 0.31, 0.23
Tasks: 176 total,   2 running, 174 sleeping,   0 stopped,   0 zombie
Cpu(s): 11.0%us,  2.1%sy,  0.0%ni, 83.3%id,  3.4%wa,  0.0%hi,  0.1%si,
0.0%st
Mem:   2057572k total,   831736k used,  1225836k free,    52424k
buffers
Swap:  5831552k total,        0k used,  5831552k free,   286568k
cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+
COMMAND

 7463 sven      20   0  270m 135m  26m R    2  6.7   1:05.52
firefox

    1 root      20   0  1652  556  488 S    0  0.0   0:01.54
init

    2 root      15  -5     0    0    0 S    0  0.0   0:00.00
kthreadd

    3 root      RT  -5     0    0    0 S    0  0.0   0:00.00
migration/0

    4 root      15  -5     0    0    0 S    0  0.0   0:00.00
ksoftirqd/0

    5 root      RT  -5     0    0    0 S    0  0.0   0:00.00
migration/1

    6 root      15  -5     0    0    0 S    0  0.0   0:00.00
ksoftirqd/1

    7 root      15  -5     0    0    0 S    0  0.0   0:00.00
cpuset

    8 root      15  -5     0    0    0 S    0  0.0   0:00.23
events/0

    9 root      15  -5     0    0    0 S    0  0.0   0:00.00
events/1

   10 root      15  -5     0    0    0 S    0  0.0   0:00.00
work_on_cpu/0

   11 root      15  -5     0    0    0 S    0  0.0   0:00.00
work_on_cpu/1

   12 root      15  -5     0    0    0 S    0  0.0   0:00.01
khelper

   15 root      15  -5     0    0    0 S    0  0.0   0:00.00
netns

  242 root      15  -5     0    0    0 S    0  0.0   0:00.00
kintegrityd/0

  243 root      15  -5     0    0    0 S    0  0.0   0:00.00
kintegrityd/1

  244 root      15  -5     0    0    0 S    0  0.0   0:00.00
kblockd/0

  245 root      15  -5     0    0    0 S    0  0.0   0:00.00
kblockd/1

  248 root      15  -5     0    0    0 S    0  0.0   0:00.00
kacpid

  249 root      15  -5     0    0    0 S    0  0.0   0:00.00
kacpi_notify

  317 root      15  -5     0    0    0 S    0  0.0   0:00.00
cqueue

  325 root      15  -5     0    0    0 S    0  0.0   0:00.01
ata/0

  326 root      15  -5     0    0    0 S    0  0.0   0:00.00
ata/1

  327 root      15  -5     0    0    0 S    0  0.0   0:00.00
ata_aux

  329 root      15  -5     0    0    0 S    0  0.0   0:00.00
ksuspend_usbd

  335 root      15  -5     0    0    0 S    0  0.0   0:00.00
khubd

  338 root      15  -5     0    0    0 S    0  0.0   0:00.00
kseriod

  379 root      15  -5     0    0    0 S    0  0.0   0:00.00
khpsbpkt

  415 root      20   0     0    0    0 S    0  0.0   0:00.00
pdflush

  416 root      20   0     0    0    0 S    0  0.0   0:00.00
pdflush

  417 root      15  -5     0    0    0 S    0  0.0   0:00.00
kswapd0

  467 root      15  -5     0    0    0 S    0  0.0   0:00.00
aio/0

  468 root      15  -5     0    0    0 S    0  0.0   0:00.00
aio/1

  497 root      15  -5     0    0    0 S    0  0.0   0:00.00
ecryptfs-kthrea

  499 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsiod

  509 root      15  -5     0    0    0 S    0  0.0   0:00.00
cifsoplockd

  510 root      15  -5     0    0    0 S    0  0.0   0:00.00
cifsdnotifyd

  524 root      15  -5     0    0    0 S    0  0.0   0:00.00
jfsIO

  525 root      15  -5     0    0    0 S    0  0.0   0:00.00
jfsCommit

  526 root      15  -5     0    0    0 S    0  0.0   0:00.00
jfsCommit

  527 root      15  -5     0    0    0 S    0  0.0   0:00.00
jfsSync

  535 root      15  -5     0    0    0 S    0  0.0   0:00.00
xfs_mru_cache

  536 root      15  -5     0    0    0 S    0  0.0   0:00.00
xfslogd/0

  537 root      15  -5     0    0    0 S    0  0.0   0:00.00
xfslogd/1

  538 root      15  -5     0    0    0 S    0  0.0   0:00.00
xfsdatad/0

  539 root      15  -5     0    0    0 S    0  0.0   0:00.00
xfsdatad/1

  545 root      15  -5     0    0    0 S    0  0.0   0:00.00
aufsd

  546 root      15  -5     0    0    0 S    0  0.0   0:00.00
aufsd

  547 root      15  -5     0    0    0 S    0  0.0   0:00.00
aufsd

  548 root      15  -5     0    0    0 S    0  0.0   0:00.00
aufsd

 1267 root      15  -5     0    0    0 S    0  0.0   0:00.00
iscsi_eh

 1354 root      15  -5     0    0    0 S    0  0.0   0:00.00
scsi_eh_2

 1356 root      15  -5     0    0    0 S    0  0.0   0:00.00
scsi_eh_3

 1413 root      15  -5     0    0    0 S    0  0.0   0:00.00
scsi_eh_4

 1415 root      15  -5     0    0    0 S    0  0.0   0:00.00
scsi_eh_5

 1447 root      15  -5     0    0    0 S    0  0.0   0:00.00
exec-osm/0

 1448 root      15  -5     0    0    0 S    0  0.0   0:00.00
exec-osm/1

 1455 root      15  -5     0    0    0 S    0  0.0   0:00.00
block-osm/0

 1456 root      15  -5     0    0    0 S    0  0.0   0:00.00
block-osm/1

 1490 root      15  -5     0    0    0 S    0  0.0   0:00.00
kpsmoused

 1497 root      15  -5     0    0    0 S    0  0.0   0:00.00
kstriped

 1499 root      15  -5     0    0    0 S    0  0.0   0:00.00
ksnapd

 1502 root      15  -5     0    0    0 S    0  0.0   0:00.00
edac-poller

 1505 root      15  -5     0    0    0 S    0  0.0   0:00.00
kondemand/0

 1506 root      15  -5     0    0    0 S    0  0.0   0:00.00
kondemand/1

 1511 root      15  -5     0    0    0 S    0  0.0   0:00.00
hid_compat

 1547 root      15  -5     0    0    0 S    0  0.0   0:00.00
rpciod/0

 1548 root      15  -5     0    0    0 S    0  0.0   0:00.00
rpciod/1

 3779 root      15  -5     0    0    0 S    0  0.0   0:00.00
dm-bbr/0

 3780 root      15  -5     0    0    0 S    0  0.0   0:00.00
dm-bbr/1

 4038 root      15  -5     0    0    0 S    0  0.0   0:00.03
kjournald2

 4212 root      16  -4  2112  824  388 S    0  0.0   0:00.14
udevd

 5393 root      15  -5     0    0    0 S    0  0.0   0:00.00
irda_sir_wq

 5526 root      15  -5     0    0    0 S    0  0.0   0:00.00
hd-audio0

 5640 root      15  -5     0    0    0 S    0  0.0   0:00.20
phy0

 5831 root      15  -5     0    0    0 S    0  0.0   0:00.00
kjournald

 6079 mysql     20   0  124m  22m 3572 S    0  1.1   0:00.17
mysqld

 6129 root      20   0 29276 9728 3704 S    0  0.5   0:00.06
apache2

 6133 apache    20   0 29276 7956 1920 S    0  0.4   0:00.00
apache2

 6134 apache    20   0 29276 7948 1912 S    0  0.4   0:00.00
apache2

 6136 apache    20   0 29276 7948 1912 S    0  0.4   0:00.00
apache2

 6137 apache    20   0 29276 7948 1912 S    0  0.4   0:00.00
apache2

 6138 apache    20   0 29276 7948 1912 S    0  0.4   0:00.00
apache2

 6318 messageb  20   0  2644 1180  640 S    0  0.1   0:00.62
dbus-daemon

 6360 haldaemo  20   0  5804 3968 3320 S    0  0.2   0:00.31
hald

 6363 root      20   0  8532 2092 1356 S    0  0.1   0:00.01
console-kit-dae

 6364 root      20   0  2856 1036  852 S    0  0.1   0:00.00
hald-runner

 6461 root      20   0  2916  972  844 S    0  0.0   0:00.08
hald-addon-inpu

 6472 haldaemo  20   0  2832  960  824 S    0  0.0   0:00.00
hald-addon-acpi

 6475 root      20   0  2920  972  844 S    0  0.0   0:00.01
hald-addon-stor

 6691 root      20   0  3640  720  500 S    0  0.0   0:00.00
kdm

 6700 root      20   0  212m  75m 7580 S    0  3.7   0:45.14
X

 6725 root      20   0  2732  756  552 S    0  0.0   0:00.04
syslog-ng

 6764 root      20   0 15116 3448 2880 S    0  0.2   0:00.14
NetworkManager

 6766 root      20   0  3240 1604 1352 S    0  0.1   0:00.01
modem-manager

 6769 root      20   0  3600 1624 1296 S    0  0.1   0:00.02
wpa_supplicant

 6771 root      20   0  6260 2784 2280 S    0  0.1   0:00.01
nm-system-setti

 6792 bin       20   0  1672  464  384 S    0  0.0   0:00.00
portmap

 6797 root      20   0  4364 1564 1164 S    0  0.1   0:00.00
kdm

 6810 sven      20   0  5688 1224 1060 S    0  0.1   0:00.02
startkde

 6824 nobody    20   0  1736  700  608 S    0  0.0   0:00.00
rpc.statd

 6855 avahi     20   0  2636 1472 1216 S    0  0.1   0:00.01
avahi-daemon

 6857 avahi     20   0  2636  516  308 S    0  0.0   0:00.00
avahi-daemon

 6879 root      20   0 10300 2500 1760 S    0  0.1   0:00.00
cupsd

 6907 root      20   0  1836  292  164 S    0  0.0   0:00.00
rpc.mountd

 6911 root      15  -5     0    0    0 S    0  0.0   0:00.00
lockd

 6912 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd4

 6913 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6914 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6915 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6916 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6917 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6918 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6919 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6920 root      15  -5     0    0    0 S    0  0.0   0:00.00
nfsd

 6981 root      20   0  2912  944  824 S    0  0.0   0:00.00
hald-addon-rfki

 7015 sven      20   0  3004  788  524 S    0  0.0   0:00.00
dbus-launch

 7017 sven      20   0  2496 1076  584 S    0  0.1   0:00.37
dbus-daemon

 7033 sven      20   0 30672 5336 3760 S    0  0.3   0:00.05
kdeinit4

 7035 sven      20   0 33524 9680 8292 S    0  0.5   0:00.08
klauncher

 7048 sven      20   0  132m  23m  16m S    0  1.2   0:00.99
kded4

 7193 root      20   0  4896  972  588 S    0  0.0   0:00.00
sshd

 7207 sven      20   0  2776 1204  952 S    0  0.1   0:00.00
gam_server

 7214 root      20   0  1892  604  504 S    0  0.0   0:00.00
dhcdbd

 7231 root      20   0  1776  288  216 S    0  0.0   0:00.00
mdadm

 7249 root      20   0 13532 2416 1540 S    0  0.1   0:00.00
smbd

 7254 root      20   0  9344 1264  788 S    0  0.1   0:00.00
nmbd

 7307 root      20   0 13532 1180  304 S    0  0.1   0:00.00
smbd

 7309 root      20   0  5144  696  568 S    0  0.0   0:00.00
cron

 7333 root      20   0  1696  684  596 S    0  0.0   0:00.00
agetty

 7334 root      20   0  1696  680  596 S    0  0.0   0:00.00
agetty

 7335 root      20   0  1696  680  596 S    0  0.0   0:00.00
agetty

 7336 root      20   0  1696  688  596 S    0  0.0   0:00.00
agetty

 7337 root      20   0  1696  684  596 S    0  0.0   0:00.00
agetty

 7338 root      20   0  1696  684  596 S    0  0.0   0:00.00
agetty

 7373 sven      20   0  1636  364  300 S    0  0.0   0:00.00
kwrapper4

 7374 sven      20   0 93924  29m  15m S    0  1.5   0:00.21
ksmserver

 7376 sven      20   0  154m  45m  21m S    0  2.2   0:39.49
kwin

 7379 sven      20   0  141m  24m  12m S    0  1.2   0:00.63
knotify4

 7380 sven      20   0  324m  50m  23m S    0  2.5   0:16.71
plasma

 7384 sven      20   0  240m  32m  16m S    0  1.6   0:01.01
lancelot

 7386 sven      20   0 33320 5976 4088 S    0  0.3   0:00.01
kio_file

 7388 sven      20   0  2444 1232  752 S    0  0.1   0:00.44
ksysguardd

 7400 sven      20   0 65320  10m 9032 S    0  0.5   0:00.10
nepomukserver

 7402 sven      20   0 38116  14m  11m S    0  0.7   0:00.12
nepomukservices

 7405 sven      20   0 35000  12m  10m S    0  0.6   0:00.06
nepomukservices

 7406 sven      20   0 34756  11m 9.9m S    0  0.6   0:00.05
nepomukservices

 7408 sven      20   0 34940  12m  10m S    0  0.6   0:00.09 nepomukser=
vices
 7414 sven      20   0 62348  13m  10m S    0  0.7   0:00.33 kxkb
 7418 sven      20   0  250m  37m  19m S    0  1.9   0:00.63 krunner
 7426 sven      20   0 52224  10m 8432 S    0  0.5   0:00.13 kwalletd
 7433 sven      20   0 55724  14m  10m S    0  0.7   0:00.22 kmix
 7435 sven      20   0  120m  40m  29m S    0  2.0   0:04.29 kopete
 7437 sven      20   0 70972  17m  12m S    0  0.9   0:00.47 yakuake
 7440 sven      20   0  6036 1632 1324 S    0  0.1   0:00.02 bash
 7445 sven      20   0 84380  15m  11m S    0  0.8   0:00.26 kmail
 7447 sven      20   0 72772  20m  13m S    0  1.0   0:03.84 konsole
 7448 sven      20   0 98.1m  22m  17m S    0  1.1   0:02.49 okular
 7449 sven      20   0 66508  23m  17m S    0  1.2   0:00.38 kate
 7452 sven      20   0  6036 1636 1328 S    0  0.1   0:00.02 bash
 7465 sven      20   0 70096  19m  13m S    0  1.0   0:01.28 konversati=
on
 7471 sven      20   0 69008  13m  10m S    0  0.7   0:00.16 korgac
 7472 sven      20   0 53288  11m 9452 S    0  0.6   0:00.16 klipper
 7473 sven      20   0 27604 5060 3292 S    0  0.2   0:00.04 kdeinit
 7477 sven      20   0 27232 4032 2732 S    0  0.2   0:00.00 dcopserver
 7480 sven      20   0 27880 5904 4512 S    0  0.3   0:00.00 klauncher
 7482 sven      20   0  7356 2468 1984 S    0  0.1   0:00.02 gconfd-2
 7484 sven      20   0 29752 8768 6680 S    0  0.4   0:00.24 kded
 7511 root      20   0  5760 1308 1008 S    0  0.1   0:00.00 su
 7517 sven      20   0 35420  10m 7864 S    0  0.5   0:00.10 knotify
 7526 sven      20   0  9364 5292 4016 S    0  0.3   0:02.98 artsd
 7528 sven      20   0  6772 1712 1488 S    0  0.1   0:00.00 gvfsd
 7545 root      20   0  6040 1640 1328 S    0  0.1   0:00.05 bash
 7583 sven      20   0 58016  13m  10m S    0  0.7   0:00.12 kwalletman=
ager
 7629 root      20   0  1984  836  712 S    0  0.0   0:00.00 dhclient
 7697 root      20   0  2260 1064  776 R    0  0.1   0:00.00 top
--snip--

hwinfo (don't think this is usefull, but anyway... ^^)
-> http://pastebin.com/f74793b41

If you need any further information, description of the problem, or hav=
e
additional tests I could run, I'd be glad if you would tell me.
I again need to mention that the rt2500 module from serialmonkey.com wo=
rks
flawlessly with exactly the same OS and exaclty the same hardware
configuration, so this is very unlikely to be a hardware problem.
Unfortunately, it is discontinued (this is in fact the reason why I am
writing this mail now :)

Thanks and best regards,
Sven
