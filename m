From: Alban Browaeys <alban.browaeys@gmail.com>
Subject: Re: "net: remove sock_iocb" breaks ip tool - "Cannot send dump
 request : Connection refused"
Date: Thu, 05 Feb 2015 11:14:44 +0100
Message-ID: <1423131284.5723.20.camel@gmail.com>
References: <1423128961.5723.10.camel@gmail.com>
	 <20150205094135.GA2576@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:45356 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757331AbbBEKOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 05:14:48 -0500
Received: by mail-we0-f170.google.com with SMTP id w55so6776963wes.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 02:14:46 -0800 (PST)
In-Reply-To: <20150205094135.GA2576@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 f=C3=A9vrier 2015 =C3=A0 10:41 +0100, Christoph Hellwig a =C3=
=A9crit :
> On Thu, Feb 05, 2015 at 10:36:01AM +0100, Alban Browaeys wrote:
> > "ip a" returns "Cannot send dump request : Connection refused" unti=
l I
> > revert commit 7cc05662682d ("net: remove sock_iocb").
> > This as root or as user.
> >=20
> > NetworkManager is affected too.
> >=20
> > Could siocb cache the cookie ?=20
>=20
> Ca you strace what syscall on what socket causes that return?
>=20

Rebuilt the kernel with the reverted undone.
I cannot reproduce anymore !


=46or the record is the strace from when it was broken (sudo strace -f =
ip
a):  af_netlink, send

execve("/sbin/ip", ["ip", "a"], [/* 19 vars */]) =3D 0
brk(0)                                  =3D 0x59000
uname({sys=3D"Linux", node=3D"odroid.prahal.homelinux.net", ...}) =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or =
directory)
mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, =
0) =3D 0xb6f2a000
access("/etc/ld.so.preload", R_OK)      =3D 0
open("/etc/ld.so.preload", O_RDONLY|O_CLOEXEC) =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D0, ...}) =3D 0
close(3)                                =3D 0
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D195089, ...}) =3D 0
mmap2(NULL, 195089, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0xb6ed5000
close(3)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or =
directory)
open("/lib/arm-linux-gnueabihf/libdl.so.2", O_RDONLY|O_CLOEXEC) =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0(\0\1\0\0\0\240\t\0\0004\0\=
0\0"..., 512) =3D 512
lseek(3, 8664, SEEK_SET)                =3D 8664
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0=
\0"..., 1160) =3D 1160
lseek(3, 8328, SEEK_SET)                =3D 8328
read(3, "A4\0\0\0aeabi\0\1*\0\0\0\0057-A\0\6\n\7A\10\1\t\2\n\4\22"..., =
53) =3D 53
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D9824, ...}) =3D 0
mmap2(NULL, 73912, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0=
) =3D 0xb6ec2000
mprotect(0xb6ec4000, 61440, PROT_NONE)  =3D 0
mmap2(0xb6ed3000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP=
_DENYWRITE, 3, 0x1000) =3D 0xb6ed3000
close(3)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or =
directory)
open("/lib/arm-linux-gnueabihf/libc.so.6", O_RDONLY|O_CLOEXEC) =3D 3
read(3, "\177ELF\1\1\1\3\0\0\0\0\0\0\0\0\3\0(\0\1\0\0\0Mw\1\0004\0\0\0"=
=2E.., 512) =3D 512
lseek(3, 904092, SEEK_SET)              =3D 904092
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0=
\0"..., 2880) =3D 2880
lseek(3, 900644, SEEK_SET)              =3D 900644
read(3, "A4\0\0\0aeabi\0\1*\0\0\0\0057-A\0\6\n\7A\10\1\t\2\n\3\f"..., 5=
3) =3D 53
fstat64(3, {st_mode=3DS_IFREG|0755, st_size=3D906972, ...}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, =
0) =3D 0xb6f29000
mmap2(NULL, 976296, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, =
0) =3D 0xb6dd3000
mprotect(0xb6eac000, 65536, PROT_NONE)  =3D 0
mmap2(0xb6ebc000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MA=
P_DENYWRITE, 3, 0xd9000) =3D 0xb6ebc000
mmap2(0xb6ebf000, 9640, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP=
_ANONYMOUS, -1, 0) =3D 0xb6ebf000
close(3)                                =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, =
0) =3D 0xb6f28000
set_tls(0xb6f284c0, 0xb6f2d050, 0xb6f28ba8, 0xb6f284c0, 0xb6f2d050) =3D=
 0
mprotect(0xb6ebc000, 8192, PROT_READ)   =3D 0
mprotect(0xb6ed3000, 4096, PROT_READ)   =3D 0
mprotect(0xb6f2c000, 4096, PROT_READ)   =3D 0
munmap(0xb6ed5000, 195089)              =3D 0
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_ROUTE) =3D 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) =3D 0
bind(3, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D 0
getsockname(3, {sa_family=3DAF_NETLINK, pid=3D1379, groups=3D00000000},=
 [12]) =3D 0
gettimeofday({1423072550, 843516}, NULL) =3D 0
send(3, "(\0\0\0\22\0\1\3']\322T\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\=
0"..., 40, 0) =3D -1 ECONNREFUSED (Connection refused)
dup(2)                                  =3D 4
fcntl64(4, F_GETFL)                     =3D 0x20002 (flags O_RDWR|O_LAR=
GEFILE)
brk(0)                                  =3D 0x59000
brk(0x7a000)                            =3D 0x7a000
fstat64(4, {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(204, 65), ...}) =3D=
 0
ioctl(4, SNDCTL_TMR_TIMEBASE or SNDRV_TIMER_IOCTL_NEXT_DEVICE or TCGETS=
, {B115200 opost isig icanon echo ...}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, =
0) =3D 0xb6f27000
_llseek(4, 0, 0xbee1aa18, SEEK_CUR)     =3D -1 ESPIPE (Illegal seek)
write(4, "Cannot send dump request: Connec"..., 45Cannot send dump requ=
est: Connection refused
) =3D 45
close(4)                                =3D 0
munmap(0xb6f27000, 4096)                =3D 0
exit_group(1)                           =3D ?
+++ exited with 1 +++
