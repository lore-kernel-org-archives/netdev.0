From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.9 SMP: via-rhine cannot be upped.
Date: Mon, 25 Oct 2004 15:29:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025152913.1f003eb4@zqx3.pdx.osdl.net>
References: <200410231559.28215.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Jeff Garzik
 <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200410231559.28215.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Oct 2004 15:59:28 +0300
Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> wrote:

> I reported this yesterday but somehow managed to mess up configs
> and accidentally compiled 2.6.9 for SMP! :(
>=20
> I just checked that it does not happen on non-SMP 2.6.9.
> 2.6.9-preempt is working too.
>=20
> Here goes a problem description again.
>=20
> I have an onboard VIA eth:
>=20
> # lspci
> 00:00.0 Host bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/=
333]
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/3=
33 AGP]
> 00:0a.0 Network controller: Texas Instruments ACX 111 54Mbps Wireless I=
nterface
> 00:0c.0 Network controller: Harris Semiconductor D-Links DWL-g650 A1 (r=
ev 01)
> 00:10.0 USB Controller: VIA Technologies, Inc. VT6202 [USB 2.0 controll=
er] (rev 80)
> 00:10.1 USB Controller: VIA Technologies, Inc. VT6202 [USB 2.0 controll=
er] (rev 80)
> 00:10.2 USB Controller: VIA Technologies, Inc. VT6202 [USB 2.0 controll=
er] (rev 80)
> 00:10.3 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 82)
> 00:11.0 ISA bridge: VIA Technologies, Inc. VT8235 ISA Bridge
> 00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/=
VT823x/A/C/VT8235 PIPC Bus Master IDE (rev 06)
> 00:11.5 Multimedia audio controller: VIA Technologies, Inc. VT8233/A/82=
35/8237 AC97 Audio Controller (rev 50)
> 00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (=
rev 74)
> 01:00.0 VGA compatible controller: nVidia Corporation NV11 [GeForce2 MX=
/MX 400] (rev a1)
>=20
> It cannot be upped:
>=20
> # ip l set dev if up
> SIOCSIFFLAGS: Function not implemented
> # ifconfig if up
> SIOCSIFFLAGS: Function not implemented
> # busybox ip l set dev if up
> SIOCSIFFLAGS: Function not implemented
>=20
> (NB: ip and ifconfig are not busyboxed, they are "standard" ones)
>=20
> Strace (busybox one is smallest):
>=20
> execve("/usr/bin/busybox", ["busybox", "ip", "l", "set", "dev", "if", "=
up"], [/* 28 vars */]) =3D 0
> fcntl64(0, F_GETFD) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0
> fcntl64(1, F_GETFD) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0
> fcntl64(2, F_GETFD) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0
> uname({sys=3D"Linux", node=3D"shadow", ...}) =3D 0
> geteuid32() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 0
> getuid32() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 0
> getegid32() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 0
> getgid32() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 0
> brk(0) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0=3D 0x81ab000
> brk(0x81ac000) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D 0=
x81ac000
> socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
> ioctl(4, 0x8913, 0xbffff9e0) =A0 =A0 =A0 =A0 =A0 =A0=3D 0
> ioctl(4, 0x8914, 0xbffff9e0) =A0 =A0 =A0 =A0 =A0 =A0=3D -1 ENOSYS (Func=
tion not implemented)
> dup(2) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0=3D 5
> fcntl64(5, F_GETFL) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x2 (fl=
ags O_RDWR)
> fstat64(5, {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 2), ...}) =3D=
 0
> old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -=
1, 0) =3D 0x40000000
> _llseek(5, 0, 0xbffff830, SEEK_CUR) =A0 =A0 =3D -1 ESPIPE (Illegal seek=
)
> write(5, "SIOCSIFFLAGS: Function not imple"..., 39) =3D 39
> close(5) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D 0
> munmap(0x40000000, 4096) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D 0
> close(4) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D 0
> write(2, "BusyBox v1.00-pre8 (2004.03.31-2"..., 295) =3D 295
> _exit(1)
>=20
> I booted with init=3D/bin/sh and ran 'ip l set dev eth0 up'
> - it fails under 2.6.9-smp. This rules out my userspace setup
> being somehow involved (for example, the fact that I rename iface
> from 'eth0' to 'if' does not contribute to the bug).
>=20
> My 2.6.9-smp config is attached.

My suspicion is that the eth0 device is not actually the VIA driver
at all. Since your config builds many drivers directly into the kernel,
probably one of the others created an eth0 device.  There is no
guarantee of initialization order about which device gets created first
(at least the way network devices are done in 2.6).=20

You should investigate if there are multiple devices present
(ifconfig -a or ls /sys/class/net).  Perhaps one of the other drivers
does not correctly handle the case of hardware not being present
and leaves a ghost behind..

One way to find out would be to look at:
	/sys/class/net/eth0/device/vendor
	/sys/class/net/eth0/device/device
	/sys/class/net/eth0/device/subsystem_vendor
	/sys/class/net/eth0/device/subsystem_device
