From: Didier Raboud <didier@raboud.com>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Sun, 15 Jun 2008 15:37:09 +0200
Message-ID: <200806151537.11986.didier@raboud.com>
References: <bug-10903-10286@http.bugzilla.kernel.org/> <20080613025804.4913de04.akpm@linux-foundation.org> <Pine.LNX.4.64.0806141351500.32523@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3240565.WWnN622DCK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.infomaniak.ch ([84.16.68.90]:34403 "EHLO
	smtp2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483AbYFONms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 09:42:48 -0400
In-Reply-To: <Pine.LNX.4.64.0806141351500.32523@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3240565.WWnN622DCK
Content-Type: multipart/mixed;
  boundary="Boundary-01=_FsRVI9wgFKqiPJV"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_FsRVI9wgFKqiPJV
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le samedi 14 juin 2008 22:45:41 Ilpo J=E4rvinen, vous avez =E9crit=A0:
> On Fri, 13 Jun 2008, Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via t=
he
> > bugzilla web interface).

OK.

> > On Fri, 13 Jun 2008 02:39:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.o=
rg=20
wrote:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=3D10903
> > >
> > >            Summary: ssh connections hang with 2.6.26-rc5
> > >            Product: Networking
> > >            Version: 2.5
> > >      KernelVersion: 2.6.26-rc5
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: acme@ghostprotocols.net
> > >         ReportedBy: didier@raboud.com
> > >
> > >
> > > Latest working kernel version: 2.6.25-2
> > > Earliest failing kernel version: 2.6.26-rc5
> > > Distribution: Debian (Lenny + Sid)
> > > Hardware Environment: amd64 (Dell Latitude D630)
> > > Software Environment: KDE
> > > Problem Description:
> > >
> > > With kernel version 2.6.26-rc5, the ssh connections to remote servers
> > > randomly
> > > hang (no error message). No amelioration despite the activation of
> > > "ServerAliveInterval" on both sides.
>
> Thanks for reporting. Could you please clarify couple of things:

Hi.

I will try to, with my time and knowledge.

> Does this only happen with a particular server/servers?

I have only tried with two of my home servers. One runs 2.6.22-4-686 and th=
e=20
other 2.6.18-6-vserver-686.

> Any middleboxes in between (NAT, firewall, etc.)?

There is a ADSL router which "provides" internet to the servers by NAT. I h=
ave=20
tried from "inside" the house (so in the same subnet) and from outside: it=
=20
hangs in both cases.

The common point is my use of "iwl3945" : I have always tried the ssh=20
connections through WiFi.

> Do all ssh connections hang simultaneously?

Well... It is hard to say. As far as I have seen, no. When I get one hang, =
I=20
can successfully connect to the same server.

> How long have you waited until concluding that TCP is "hung"?

Well. The "ServerAliveInterval" option of openssh now leads to "Received=20
disconnect from $IP: 2: Timeout, your session not responding." after the=20
hang. So the openssh server notices that my session is not responding and s=
o=20
cuts the connection.

> Is TSO enabled (ethtool -k)? Have you tried without it?

Doesn't seem:

=2D---
# ethtool -k wlan0
Offload parameters for wlan0:
Cannot get device rx csum settings: Operation not supported
Cannot get device tx csum settings: Operation not supported
Cannot get device scatter-gather settings: Operation not supported
Cannot get device tcp segmentation offload settings: Operation not supported
Cannot get device udp large send offload settings: Operation not supported
Cannot get device generic segmentation offload settings: Operation not=20
supported
no offload info available
=2D---

> It wouldn't hurt to include info about eth hw too (e.g., lspci), though
> it might turn unneeded at some point of time but it might save an email
> round-trip.

lspci attached.

> TCP can appear to hang due to vast number of reasons. Only recent changes
> that are suspectable is the DEFERRED_ACCEPT thing which is already
> reverted in the very latest Linus' tree (even -rc6 is too old for that)
> and few FRTO fixes (you can exclude FRTO by turning
> /proc/sys/net/ipv4/tcp_frto sysctl to 0 but it seems quite unlikely to
> change anything); your problem might well come from something else and TCP
> hang is just a symptom of other problem downstream.

I can't understand everything, but what I can say is that with the exact sa=
me=20
software, I get no hangs with 2.6.25-2 but I get some with 2.6.26-rc5.

> So please gather this information (at least for the relevant connections):
>
> $ netstat -pn
> $ cat /proc/net/tcp

Attached.

> ...Also a tcpdump might be handy (though I don't know yet).

Well. It seems that there is another bug here: everytime I tried a

# tcpdump -w /tmp/tcpdump.wlan0 -i wlan0

I got a CPU lockup (or similar, can't know exactly, but keyboard blocked an=
d=20
nothing doable).

> ...Depending on your privacy needs, you may want obfuscate ip addresses
> that are revealed by all of those logs (ie., if you don't want to reveal
> with whom you're communicating with, ssh payload is encrypted anyway).
>=20
> (...)
>=20
> (I'll be away nearly a month after Tuesday, so I probably won't have much
> time to resolve this issue but I hope I've some time to take a look before
> I leave).

We'll see ;)

Regards,=20

OdyX

=2D-=20
Didier Raboud, proud Debian user.
CH-1802 Corseaux
didier@raboud.com

--Boundary-01=_FsRVI9wgFKqiPJV
Content-Type: text/plain;
  charset="iso-8859-1";
  name="lspci"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="lspci"

00:00.0 Host bridge: Intel Corporation Mobile PM965/GM965/GL960 Memory Controller Hub (rev 0c)
00:02.0 VGA compatible controller: Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller (rev 0c)
00:02.1 Display controller: Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller (rev 0c)
00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 02)
00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 02)
00:1c.1 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 02)
00:1c.5 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 6 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev f2)
00:1f.0 ISA bridge: Intel Corporation 82801HEM (ICH8M) LPC Interface Controller (rev 02)
00:1f.1 IDE interface: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) IDE Controller (rev 02)
00:1f.2 SATA controller: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) SATA AHCI Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 02)
03:01.0 CardBus bridge: O2 Micro, Inc. Cardbus bridge (rev 21)
03:01.4 FireWire (IEEE 1394): O2 Micro, Inc. Firewire (IEEE 1394) (rev 02)
09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M Gigabit Ethernet PCI Express (rev 02)
0c:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG Network Connection (rev 02)

--Boundary-01=_FsRVI9wgFKqiPJV
Content-Type: text/plain;
  charset="iso-8859-1";
  name="netstat_-pn"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="netstat_-pn"

Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State  =
     PID/Program name
tcp        0      0 192.168.1.11:57063      128.178.222.18:143      ESTABLI=
SHED 11314/klauncher0EyU
tcp        0      0 192.168.1.11:54596      192.168.1.3:9000        ESTABLI=
SHED 11125/klauncher0EyU
tcp        0      0 192.168.1.11:54591      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54587      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54589      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54583      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54584      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:47334      217.150.254.106:5223    ESTABLI=
SHED 4437/kopete    =20
tcp        0      0 192.168.1.11:54593      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:36357      192.168.1.2:22          TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54592      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54588      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:53858      195.144.11.40:143       ESTABLI=
SHED 4799/klauncher0EyU
tcp        0      0 192.168.1.11:54586      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54595      192.168.1.3:9000        ESTABLI=
SHED 11129/klauncher0EyU
tcp        0      0 192.168.1.11:38449      212.25.25.37:143        ESTABLI=
SHED 4801/klauncher0EyU
tcp        0      0 192.168.1.11:40539      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54590      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:54594      192.168.1.3:9000        TIME_WA=
IT   -              =20
tcp        0      0 192.168.1.11:33066      84.16.68.124:143        ESTABLI=
SHED 4800/klauncher0EyU
tcp        0      0 192.168.1.11:38525      192.168.1.3:22          ESTABLI=
SHED 13828/ssh      =20
tcp        0      0 192.168.182.18:60514    213.134.45.154:443      ESTABLI=
SHED 4666/klauncher0EyU
tcp        0      0 192.168.1.11:54585      192.168.1.3:9000        TIME_WA=
IT   -              =20
Active UNIX domain sockets (w/o servers)
Proto RefCnt Flags       Type       State         I-Node   PID/Program name=
    Path
unix  3      [ ]         DGRAM                    20699    -               =
    /var/run/wpa_supplicant/wlan0
unix  2      [ ]         DGRAM                    20625    -               =
    /var/run/wpa_supplicant-global
unix  2      [ ]         DGRAM                    20701    -               =
    /var/run/NetworkManager/wpa_ctrl_3855-19
unix  2      [ ]         DGRAM                    3393     -               =
    @/org/kernel/udev/udevd
unix  9      [ ]         DGRAM                    7553     -               =
    /dev/log
unix  2      [ ]         DGRAM                    8303     -               =
    @/org/freedesktop/hal/udev_event
unix  3      [ ]         STREAM     CONNECTED     41908    4366/klauncher [=
kde /tmp/ksocket-didier/klauncher0EyUjc.slave-socket
unix  3      [ ]         STREAM     CONNECTED     41906    4808/klauncher0E=
yUj=20
unix  3      [ ]         STREAM     CONNECTED     41564    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     41563    13658/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     41562    4467/kontact    =
    /tmp/ksocket-didier/kontact28e1Ub.slave-socket
unix  3      [ ]         STREAM     CONNECTED     41560    13658/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     41552    4467/kontact    =
    /tmp/ksocket-didier/kontactxiTI2a.slave-socket
unix  3      [ ]         STREAM     CONNECTED     41550    13657/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     38904    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     38903    13293/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     38902    4462/konqueror [=
kde /tmp/ksocket-didier/konqueroroMrdRa.slave-socket
unix  3      [ ]         STREAM     CONNECTED     38900    13293/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     28499    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     28498    4366/klauncher [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     26499    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     26498    11314/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     26486    4467/kontact    =
    /tmp/ksocket-didier/kontactoijRSa.slave-socket
unix  3      [ ]         STREAM     CONNECTED     26485    11314/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     25452    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     25451    11129/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     25450    4462/konqueror [=
kde /tmp/ksocket-didier/konqueror3DG8Oa.slave-socket
unix  3      [ ]         STREAM     CONNECTED     25448    11129/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     25432    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     25431    11125/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     25429    4462/konqueror [=
kde /tmp/ksocket-didier/konquerorCg3z9b.slave-socket
unix  3      [ ]         STREAM     CONNECTED     25425    11125/klauncher0=
EyU=20
unix  3      [ ]         STREAM     CONNECTED     22199    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     22198    4801/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     22174    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     22173    4799/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     22156    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     22155    4800/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     21407    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     21406    10664/kmix [kdei=
nit=20
unix  3      [ ]         STREAM     CONNECTED     21405    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     21402    10664/kmix [kdei=
nit=20
unix  3      [ ]         STREAM     CONNECTED     21399    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     21398    10664/kmix [kdei=
nit=20
unix  2      [ ]         DGRAM                    20736    -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     19277    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     19276    10280/kio_uiserv=
er =20
unix  3      [ ]         STREAM     CONNECTED     19275    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     19272    10280/kio_uiserv=
er =20
unix  3      [ ]         STREAM     CONNECTED     19265    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     19264    10280/kio_uiserv=
er =20
unix  3      [ ]         STREAM     CONNECTED     12984    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     12983    4666/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     12761    4467/kontact    =
    /tmp/ksocket-didier/kontactsTY3Bb.slave-socket
unix  3      [ ]         STREAM     CONNECTED     12687    4801/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     12759    4467/kontact    =
    /tmp/ksocket-didier/kontactYyQzta.slave-socket
unix  3      [ ]         STREAM     CONNECTED     12681    4800/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     12764    4467/kontact    =
    /tmp/ksocket-didier/kontactUfNfjb.slave-socket
unix  3      [ ]         STREAM     CONNECTED     12678    4799/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     11713    4368/kded [kdein=
it] /tmp/ksocket-didier/kdedN1sj7b.slave-socket
unix  3      [ ]         STREAM     CONNECTED     11712    4666/klauncher0E=
yU =20
unix  3      [ ]         STREAM     CONNECTED     11480    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     11479    4626/kttsd      =
   =20
unix  3      [ ]         STREAM     CONNECTED     11476    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     11475    4626/kttsd      =
   =20
unix  3      [ ]         STREAM     CONNECTED     11472    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     11471    4626/kttsd      =
   =20
unix  3      [ ]         STREAM     CONNECTED     11448    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     11447    4621/kwalletmana=
ger=20
unix  3      [ ]         STREAM     CONNECTED     11440    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     11439    4621/kwalletmana=
ger=20
unix  3      [ ]         STREAM     CONNECTED     11436    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     11435    4621/kwalletmana=
ger=20
unix  3      [ ]         STREAM     CONNECTED     11399    4612/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     11398    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     11397    4612/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     11396    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     11395    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     11394    4612/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     11392    4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     11391    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10985    4427/artsd      =
    /tmp/ksocket-didier/Tamino-114b-48551204
unix  3      [ ]         STREAM     CONNECTED     10984    4504/knotify [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10899    -               =
    /var/run/sdp
unix  3      [ ]         STREAM     CONNECTED     10898    4514/kbluetooth =
   =20
unix  3      [ ]         STREAM     CONNECTED     10890    -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     10889    4514/kbluetooth =
   =20
unix  3      [ ]         STREAM     CONNECTED     10888    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10887    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10884    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10883    4462/konqueror [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     10882    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10881    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10878    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10877    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10872    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10871    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10859    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10858    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10840    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10839    4514/kbluetooth =
   =20
unix  3      [ ]         STREAM     CONNECTED     10838    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10837    4514/kbluetooth =
   =20
unix  3      [ ]         STREAM     CONNECTED     10834    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10833    4514/kbluetooth =
   =20
unix  3      [ ]         STREAM     CONNECTED     10809    -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     10808    4475/python     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10805    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10804    4475/python     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10768    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10767    4475/python     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10741    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10740    4504/knotify [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10723    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10722    4504/knotify [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10718    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10717    4504/knotify [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10656    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10655    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10652    -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     10651    4486/kpowersave =
[kd=20
unix  3      [ ]         STREAM     CONNECTED     10646    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10645    4488/klipper [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10642    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10641    4488/klipper [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10640    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10639    4488/klipper [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10628    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10627    4486/kpowersave =
[kd=20
unix  3      [ ]         STREAM     CONNECTED     10624    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10623    4486/kpowersave =
[kd=20
unix  3      [ ]         STREAM     CONNECTED     10622    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10621    4486/kpowersave =
[kd=20
unix  3      [ ]         STREAM     CONNECTED     10612    4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     10611    4482/korgac     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10608    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10607    4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     10603    -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     10602    4483/knetworkman=
age=20
unix  3      [ ]         STREAM     CONNECTED     10591    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10590    4483/knetworkman=
age=20
unix  3      [ ]         STREAM     CONNECTED     10587    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10586    4483/knetworkman=
age=20
unix  3      [ ]         STREAM     CONNECTED     10585    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10584    4483/knetworkman=
age=20
unix  3      [ ]         STREAM     CONNECTED     10573    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10572    4482/korgac     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10569    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10568    4482/korgac     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10567    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10566    4482/korgac     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10562    4481/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10561    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10560    4481/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10559    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10558    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10557    4481/ispell     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10486    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10485    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10482    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10481    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10480    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10479    4467/kontact    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10471    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10470    4462/konqueror [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     10463    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10462    4462/konqueror [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     10461    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10460    4462/konqueror [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     10433    4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     10432    4437/kopete     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10352    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10351    4437/kopete     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10349    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10348    4437/kopete     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10346    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10345    4437/kopete     =
   =20
unix  3      [ ]         STREAM     CONNECTED     10329    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10328    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10321    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10320    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10319    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10318    4433/katapult   =
   =20
unix  3      [ ]         STREAM     CONNECTED     10310    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10309    4432/yakuake    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10306    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10305    4432/yakuake    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10304    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10303    4432/yakuake    =
   =20
unix  3      [ ]         STREAM     CONNECTED     10292    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10291    4430/kgpg       =
   =20
unix  3      [ ]         STREAM     CONNECTED     10288    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10287    4430/kgpg       =
   =20
unix  3      [ ]         STREAM     CONNECTED     10286    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10285    4430/kgpg       =
   =20
unix  3      [ ]         STREAM     CONNECTED     10216    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10215    4412/kaccess [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10212    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10211    4412/kaccess [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10210    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10209    4412/kaccess [kd=
ein=20
unix  3      [ ]         STREAM     CONNECTED     10184    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10183    4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     10130    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10129    4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     10095    4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     10094    4395/kweatherser=
vic=20
unix  3      [ ]         STREAM     CONNECTED     10091    -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     10090    4395/kweatherser=
vic=20
unix  3      [ ]         STREAM     CONNECTED     10087    4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     10086    4395/kweatherser=
vic=20
unix  3      [ ]         STREAM     CONNECTED     9883     4392/sh         =
   =20
unix  3      [ ]         STREAM     CONNECTED     9882     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9881     4392/sh         =
   =20
unix  3      [ ]         STREAM     CONNECTED     9880     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9879     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9878     4392/sh         =
   =20
unix  3      [ ]         STREAM     CONNECTED     9855     4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     9854     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9852     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     9851     4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9799     4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     9798     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9796     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9794     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9791     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9790     4385/kicker [kde=
ini=20
unix  3      [ ]         STREAM     CONNECTED     9785     4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     9784     4383/kdesktop [k=
dei=20
unix  3      [ ]         STREAM     CONNECTED     9773     4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     9772     4383/kdesktop [k=
dei=20
unix  3      [ ]         STREAM     CONNECTED     9771     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9770     4383/kdesktop [k=
dei=20
unix  3      [ ]         STREAM     CONNECTED     9765     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9764     4383/kdesktop [k=
dei=20
unix  3      [ ]         STREAM     CONNECTED     9757     4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     9756     4381/kwin [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9754     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9753     4381/kwin [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9748     4380/ksmserver [=
kde /tmp/.ICE-unix/4380
unix  3      [ ]         STREAM     CONNECTED     9747     4381/kwin [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9746     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9745     4381/kwin [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9738     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9737     4380/ksmserver [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     9732     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9731     4380/ksmserver [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     9722     4380/ksmserver [=
kde /tmp/ksocket-didier/kdeinit__0
unix  3      [ ]         STREAM     CONNECTED     9721     4378/kwrapper   =
   =20
unix  3      [ ]         STREAM     CONNECTED     9667     4370/gam_server =
    @/tmp/fam-didier-
unix  3      [ ]         STREAM     CONNECTED     9666     4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9648     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9647     4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9646     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9645     4368/kded [kdein=
it]=20
unix  3      [ ]         STREAM     CONNECTED     9634     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9633     4360/kdeinit Run=
nin=20
unix  3      [ ]         STREAM     CONNECTED     9626     4363/dcopserver =
[kd /tmp/.ICE-unix/dcop4363-1213534701
unix  3      [ ]         STREAM     CONNECTED     9625     4366/klauncher [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     9619     4366/klauncher [=
kde=20
unix  3      [ ]         STREAM     CONNECTED     9618     4360/kdeinit Run=
nin=20
unix  3      [ ]         STREAM     CONNECTED     9525     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9524     4321/dbus-launch=
   =20
unix  3      [ ]         STREAM     CONNECTED     9523     4322/dbus-daemon=
   =20
unix  3      [ ]         STREAM     CONNECTED     9522     4322/dbus-daemon=
   =20
unix  5      [ ]         STREAM     CONNECTED     9509     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     9508     4321/dbus-launch=
   =20
unix  2      [ ]         DGRAM                    9445     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     9442     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     9441     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     9232     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     9231     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8690     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     8689     -               =
   =20
unix  2      [ ]         DGRAM                    8685     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8610     -               =
    @/var/run/hald/dbus-dV87ZJjdJn
unix  3      [ ]         STREAM     CONNECTED     8608     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8607     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     8606     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8609     -               =
    @/var/run/hald/dbus-dV87ZJjdJn
unix  3      [ ]         STREAM     CONNECTED     8604     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8495     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     8494     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8493     -               =
    @/var/run/hald/dbus-dV87ZJjdJn
unix  3      [ ]         STREAM     CONNECTED     8492     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8490     -               =
    /var/run/acpid.socket
unix  3      [ ]         STREAM     CONNECTED     8489     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8484     -               =
    @/var/run/hald/dbus-dV87ZJjdJn
unix  3      [ ]         STREAM     CONNECTED     8483     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8462     -               =
    @/var/run/hald/dbus-dV87ZJjdJn
unix  3      [ ]         STREAM     CONNECTED     8461     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8412     -               =
    /var/run/acpid.socket
unix  3      [ ]         STREAM     CONNECTED     8411     -               =
   =20
unix  8      [ ]         STREAM     CONNECTED     9233     -               =
    /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     8391     -               =
   =20
unix  2      [ ]         DGRAM                    8206     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8188     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     8187     -               =
   =20
unix  2      [ ]         DGRAM                    8171     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8161     -               =
    @/var/run/hald/dbus-2dFKypkmSh
unix  3      [ ]         STREAM     CONNECTED     8160     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     8136     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     8135     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     7998     -               =
    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     7997     -               =
   =20
unix  2      [ ]         DGRAM                    7996     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     7985     -               =
   =20
unix  3      [ ]         STREAM     CONNECTED     7984     -               =
   =20
unix  2      [ ]         DGRAM                    7812     -               =
   =20

--Boundary-01=_FsRVI9wgFKqiPJV
Content-Type: text/plain;
  charset="iso-8859-1";
  name="proc_net_tcp"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="proc_net_tcp"

  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt=
   uid  timeout inode                                                    =20
   0: 00000000:1F4A 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
  1000        0 31010 1 ffff81007b962d80 750 0 0 2 -1                    =20
   1: 00000000:008B 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
     0        0 8628 1 ffff81007b963400 750 0 0 2 -1                     =20
   2: 00000000:006F 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
     0        0 7080 1 ffff81007d9693c0 750 0 0 2 -1                     =20
   3: 0100007F:0277 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
     0        0 8079 1 ffff81007d9686c0 750 0 0 2 -1                     =20
   4: 0100007F:0019 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
     0        0 8059 1 ffff81007d968040 750 0 0 2 -1                     =20
   5: 00000000:01BD 00000000:0000 0A 00000000:00000000 00:00000000 00000000=
     0        0 8627 1 ffff81007d968d40 750 0 0 2 -1                     =20
   6: 0B01A8C0:DEE7 12DEB280:008F 01 00000000:00000000 00:00000000 00000000=
  1000        0 26497 1 ffff8100515af4c0 60 10 30 4 -1                   =20
   7: 0B01A8C0:D544 0301A8C0:2328 06 00000000:00000000 03:00000EAE 00000000=
     0        0 0 2 ffff810051163780                                     =20
   8: 0B01A8C0:D53F 0301A8C0:2328 06 00000000:00000000 03:000004F8 00000000=
     0        0 0 2 ffff8100514d6980                                     =20
   9: 0B01A8C0:D53D 0301A8C0:2328 06 00000000:00000000 03:000002BA 00000000=
     0        0 0 2 ffff8100514d6e80                                     =20
  10: 0B01A8C0:B8E6 6AFE96D9:1467 01 00000000:00000000 00:00000000 00000000=
  1000        0 31018 1 ffff810042ac0900 63 10 26 4 -1                   =20
  11: 0B01A8C0:D541 0301A8C0:2328 06 00000000:00000000 03:000008F2 00000000=
     0        0 0 2 ffff810051163880                                     =20
  12: 0B01A8C0:D54A 0301A8C0:2328 01 00000000:00000000 00:00000000 00000000=
  1000        0 43377 1 ffff8100515aee40 54 10 4 5 -1                    =20
  13: 0B01A8C0:D540 0301A8C0:2328 06 00000000:00000000 03:000006F2 00000000=
     0        0 0 2 ffff810051163380                                     =20
  14: 0B01A8C0:D262 280B90C3:008F 01 00000000:00000000 00:00000000 00000000=
  1000        0 22172 1 ffff81004b8c7700 64 10 30 4 -1                   =20
  15: 0B01A8C0:D543 0301A8C0:2328 06 00000000:00000000 03:00000CEB 00000000=
     0        0 0 2 ffff8100514d6280                                     =20
  16: 0B01A8C0:D546 0301A8C0:2328 06 00000000:00000000 03:000010E9 00000000=
     0        0 0 2 ffff8100514d6380                                     =20
  17: 0B01A8C0:9631 251919D4:008F 01 00000000:00000000 00:00000000 00000000=
  1000        0 22194 1 ffff81004b8c7080 67 10 28 4 -1                   =20
  18: 0B01A8C0:D545 0301A8C0:2328 06 00000000:00000000 03:00000EEB 00000000=
     0        0 0 2 ffff8100514d6a80                                     =20
  19: 0B01A8C0:D54B 0301A8C0:2328 01 00000000:00000000 00:00000000 00000000=
  1000        0 43424 1 ffff810042ac0f80 54 10 4 5 -1                    =20
  20: 0B01A8C0:D53E 0301A8C0:2328 06 00000000:00000000 03:000002F2 00000000=
     0        0 0 2 ffff8100514d6780                                     =20
  21: 0B01A8C0:D549 0301A8C0:2328 06 00000000:00000000 03:000016DD 00000000=
     0        0 0 2 ffff8100514d6b80                                     =20
  22: 0B01A8C0:D542 0301A8C0:2328 06 00000000:00000000 03:00000AE8 00000000=
     0        0 0 2 ffff810051163280                                     =20
  23: 0B01A8C0:D547 0301A8C0:2328 06 00000000:00000000 03:000012E2 00000000=
     0        0 0 2 ffff8100514d6480                                     =20
  24: 0B01A8C0:812A 7C441054:008F 01 00000000:00000000 00:00000000 00000000=
  1000        0 22154 1 ffff8100510da0c0 60 10 30 4 3                    =20
  25: 0B01A8C0:D548 0301A8C0:2328 06 00000000:00000000 03:000014DF 00000000=
     0        0 0 2 ffff8100514d6c80                                     =20
  26: 0B01A8C0:967D 0301A8C0:0016 01 00000000:00000000 02:000AD441 00000000=
  1000        0 42496 2 ffff81007b962080 54 10 25 4 -1                   =20
  27: 12B6A8C0:EC62 9A2D86D5:01BB 01 00000000:00000000 00:00000000 00000000=
  1000        0 12944 1 ffff8100515ae140 77 10 4 5 -1                    =20

--Boundary-01=_FsRVI9wgFKqiPJV--

--nextPart3240565.WWnN622DCK
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkhVGwUACgkQwW1nnOmiePD/4gCdGzU/dJe0RU37rYFtdvqu3QEB
K6wAmwSLcPk8p3wlTB7T4SF/cLWxiRX1
=C551
-----END PGP SIGNATURE-----

--nextPart3240565.WWnN622DCK--
