From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Fwd: Bug#488430: iproute: lnstat causes segmentation fault]
Date: Mon, 30 Jun 2008 10:36:25 -0700
Message-ID: <20080630103625.7e718a93@extreme>
References: <1214733409.16171.43.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	Andrew France <andrew@avito.co.uk>, 488430@bugs.debian.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55317 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYF3Rg1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 13:36:27 -0400
In-Reply-To: <1214733409.16171.43.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Jun 2008 11:56:49 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> Hi Stephen and others interested!
>=20
> Could you please have a look at lnstat. We got a bugreport in Debian
> about it segfaulting. It happens for me too on my workstation (amd64)=
,
> which is also my internet gateway at home, but not on my laptop (i386=
).
>=20
> I can't figure out what's going on. =EF=BB=BFThe segfault only happen=
s when
> lnstat is compiled with atleast -O1. It seems like the fp->params arr=
ay
> is getting corrupted at 65th element inside build_hdr_string() at the
> first for loop where memory is malloced and memset. That seems totall=
y
> unrelated to me though, could it be something like use of freed memor=
y?
> I have no clue...
>=20
> In case you can't reproduce, I've made a tarball of my /proc/net/stat
> and attached, which I hope helps.
>=20
> PS. any news on the debian front (stuff sent to 488430@bugs.debian.or=
g)
> will be available through http://bugs.debian.org/488430 (and other
> problems at http://bugs.debian.org/iproute ).
>=20
>=20
>=20
> -------- Forwarded Message --------
> From: Andrew France <andrew@avito.co.uk>
> Reply-To: Andrew France <andrew@avito.co.uk>, 488430@bugs.debian.org
> To: Debian Bug Tracking System <submit@bugs.debian.org>
> Subject: Bug#488430: iproute: lnstat causes segmentation fault
> Date: Sat, 28 Jun 2008 21:30:06 +0100
>=20
> Package: iproute
> Version: 20080417-1
> Severity: important
>=20
> Hi,
>=20
> Running 'lnstat' results in a segmentation fault, although the symlin=
ked
> 'rtstat' runs fine. Lnstat strace included below.
>=20
>=20
> -- System Information:
> Debian Release: lenny/sid
>   APT prefers testing
>   APT policy: (500, 'testing')
> Architecture: amd64 (x86_64)
>=20
> Kernel: Linux 2.6.24-1-amd64 (SMP w/2 CPU cores)
> Locale: LANG=3Den_GB.UTF-8, LC_CTYPE=3Den_GB.UTF-8 (charmap=3DUTF-8)
> Shell: /bin/sh linked to /bin/bash
>=20
> Versions of packages iproute depends on:
> ii  libc6                         2.7-10     GNU C Library: Shared li=
braries
> ii  libdb4.6                      4.6.21-8   Berkeley v4.6 Database L=
ibraries [
>=20
> Versions of packages iproute recommends:
> ii  libatm1                       2.4.1-17.2 shared library for ATM (=
Asynchrono
>=20
> -- no debconf information
>=20
> *** lnstat.strace
> execve("/usr/bin/lnstat", ["lnstat"], [/* 22 vars */]) =3D 0
> brk(0)                                  =3D 0x604000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210df000
> access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file o=
r directory)
> mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e0000
> access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT (No such file o=
r directory)
> open("/etc/ld.so.cache", O_RDONLY)      =3D 3
> fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D36821, ...}) =3D 0
> mmap(NULL, 36821, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x2b0f210e2000
> close(3)                                =3D 0
> access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file o=
r directory)
> open("/lib/libresolv.so.2", O_RDONLY)   =3D 3
> read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P3\0\0\0"..., =
832) =3D 832
> fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D72568, ...}) =3D 0
> mmap(NULL, 2177800, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3=
, 0) =3D 0x2b0f212e0000
> mprotect(0x2b0f212f0000, 2097152, PROT_NONE) =3D 0
> mmap(0x2b0f214f0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXE=
D|MAP_DENYWRITE, 3, 0x10000) =3D 0x2b0f214f0000
> mmap(0x2b0f214f2000, 6920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXE=
D|MAP_ANONYMOUS, -1, 0) =3D 0x2b0f214f2000
> close(3)                                =3D 0
> access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file o=
r directory)
> open("/lib/libc.so.6", O_RDONLY)        =3D 3
> read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\342"..., =
832) =3D 832
> fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D1330480, ...}) =3D 0
> mmap(NULL, 3437144, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3=
, 0) =3D 0x2b0f214f4000
> mprotect(0x2b0f21632000, 2097152, PROT_NONE) =3D 0
> mmap(0x2b0f21832000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIX=
ED|MAP_DENYWRITE, 3, 0x13e000) =3D 0x2b0f21832000
> mmap(0x2b0f21837000, 16984, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIX=
ED|MAP_ANONYMOUS, -1, 0) =3D 0x2b0f21837000
> close(3)                                =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f2183c000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f2183d000
> arch_prctl(ARCH_SET_FS, 0x2b0f2183caf0) =3D 0
> mprotect(0x2b0f21832000, 12288, PROT_READ) =3D 0
> munmap(0x2b0f210e2000, 36821)           =3D 0
> open("/proc/net/stat", O_RDONLY|O_NONBLOCK|O_DIRECTORY|0x80000) =3D 3
> fstat(3, {st_mode=3DS_IFDIR|0555, st_size=3D0, ...}) =3D 0
> fcntl(3, F_GETFD)                       =3D 0x1 (flags FD_CLOEXEC)
> brk(0)                                  =3D 0x604000
> brk(0x625000)                           =3D 0x625000
> getdents(3, /* 8 entries */, 1024)      =3D 248
> open("/proc/net/stat/ip_conntrack", O_RDONLY) =3D 4
> fstat(4, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e2000
> lseek(4, 0, SEEK_SET)                   =3D 0
> read(4, "entries  searched found new inva"..., 1024) =3D 444
> open("/proc/net/stat/nf_conntrack", O_RDONLY) =3D 5
> fstat(5, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e3000
> lseek(5, 0, SEEK_SET)                   =3D 0
> read(5, "entries  searched found new inva"..., 1024) =3D 444
> open("/proc/net/stat/ndisc_cache", O_RDONLY) =3D 6
> fstat(6, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e4000
> lseek(6, 0, SEEK_SET)                   =3D 0
> read(6, "entries  allocs destroys hash_gr"..., 1024) =3D 338
> open("/proc/net/stat/clip_arp_cache", O_RDONLY) =3D 7
> fstat(7, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e5000
> lseek(7, 0, SEEK_SET)                   =3D 0
> read(7, "entries  allocs destroys hash_gr"..., 1024) =3D 338
> open("/proc/net/stat/rt_cache", O_RDONLY) =3D 8
> fstat(8, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e6000
> lseek(8, 0, SEEK_SET)                   =3D 0
> read(8, "entries  in_hit in_slow_tot in_s"..., 1024) =3D 517
> open("/proc/net/stat/arp_cache", O_RDONLY) =3D 9
> fstat(9, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,=
 0) =3D 0x2b0f210e7000
> lseek(9, 0, SEEK_SET)                   =3D 0
> read(9, "entries  allocs destroys hash_gr"..., 1024) =3D 338
> getdents(3, /* 0 entries */, 1024)      =3D 0
> close(3)                                =3D 0
> mmap(NULL, 6356992, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, =
-1, 0) =3D 0x2b0f2183e000
> munmap(0x2b0f2183e000, 6356992)         =3D 0
> brk(0xc42000)                           =3D 0xc42000
> --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> +++ killed by SIGSEGV +++
> Process 19271 detached
>=20
>=20


The problem is that MAX_FIELDS is 64, but lnstat is finding 71 fields.
This causes a array out of range problem.

Just bump MAX_FIELDS to 128
