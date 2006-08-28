From: "Miles Lane" <miles.lane@gmail.com>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an "eth" device name
Date: Mon, 28 Aug 2006 08:52:02 -0700
Message-ID: <a44ae5cd0608280852p50e72241vff8e3ae101e94185@mail.gmail.com>
References: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com>
	 <20060827001943.c559d37d.akpm@osdl.org>
	 <20060827.003800.95504796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:24542 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751079AbWH1PwD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 11:52:03 -0400
Received: by py-out-1112.google.com with SMTP id n25so2524772pyg
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 08:52:02 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>,
	"Dan Williams" <dcbw@redhat.com>
In-Reply-To: <20060827.003800.95504796.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/06, David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@osdl.org>
> Date: Sun, 27 Aug 2006 00:19:43 -0700
>
> > Jeremy reported that a while back too.  I do not know what is causi=
ng it
> > and as far as I know no net developers have yet looked into it.
>
> A debugging patch like this one should help figure out the culprit.
>
> If we don't see the gibberish netdevice name printed in the kernel
> logs, then likely something is corrupting the netdevice structure or
> the memory holding the name.
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d4a1ec3..45f9b19 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -738,6 +738,11 @@ int dev_change_name(struct net_device *d
>
>         if (!dev_valid_name(newname))
>                 return -EINVAL;
> +#if 1
> +       printk("[%s:%d]: Changing netdevice name from [%s] to [%s]\n"=
,
> +              current->comm, current->pid,
> +              dev->name, newname);
> +#endif
>
>         if (strchr(newname, '%')) {
>                 err =3D dev_alloc_name(dev, newname);
>

Dan, do you have any idea why NetworkManager from Ubuntu 6.06.1
would be corrupting network device names on recent MM kernels?
I haven't seen this happening with Ubuntu's kernels.  If you like, I ca=
n
send you my kernel .config file.

Here's what I get:

[NetworkManager:5399]: Changing netdevice name from [eth0] to [=EF=BF=BD=
=EF=BF=BD]
=EF=BF=BD=EF=BF=BD: link down
ADDRCONF(NETDEV_UP): =EF=BF=BD=EF=BF=BD: link is not ready
[NetworkManager:5399]: Changing netdevice name from [eth1] to [7G*e]
7G*e: no IPv6 routers present

Here's the result of "strace -f -F -v -a50 NetworkManager:

execve("./NetworkManager.bak", ["./NetworkManager.bak"],
["TERM=3Dlinux", "SHELL=3D/bin/bash", "HUSHLOGIN=3DFALSE",
"OLDPWD=3D/home/miles", "USER=3Droot",
"LS_COLORS=3Dno=3D00:fi=3D00:di=3D01;34:l"..., "SUDO_USER=3Dmiles",
"SUDO_UID=3D1000", "PATH=3D/usr/local/sbin:/usr/local/"...,
"MAIL=3D/var/mail/miles", "PWD=3D/usr/sbin", "LANG=3Den_US.UTF-8",
"HISTCONTROL=3Dignoredups", "SUDO_COMMAND=3D/bin/bash",
"HOME=3D/home/miles", "SHLVL=3D2", "LANGUAGE=3Den_US:en_GB:en",
"LOGNAME=3Droot", "LESSOPEN=3D| /usr/bin/lesspipe %s", "SUDO_GID=3D1000=
",
"LESSCLOSE=3D/usr/bin/lesspipe %s %"..., "_=3D/usr/bin/strace"]) =3D 0
uname({sysname=3D"Linux", nodename=3D"Dumbleedor",
release=3D"2.6.18-rc4-mm3", version=3D"#32 Sun Aug 27 01:01:35 PDT 2006=
",
machine=3D"i686"}) =3D 0
brk(0)                                            =3D 0x808b000
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7f8a000
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
old_mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7f88000
access("/etc/ld.so.preload", R_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/etc/ld.so.cache", O_RDONLY)                =3D 3
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D195836,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D216, st_size=3D102666, st_atime=3D2006/08/28-00:34:02,
st_mtime=3D2006/08/25-22:58:56, st_ctime=3D2006/08/25-22:58:56}) =3D 0
old_mmap(NULL, 102666, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0xb7f6e000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libhal.so.1", O_RDONLY)            =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\36\0"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D830757,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D64, st_size=3D30448, st_atime=3D2006/08/28-00:34:02,
st_mtime=3D2006/05/22-08:09:25, st_ctime=3D2006/07/05-21:10:31}) =3D 0
old_mmap(NULL, 33464, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f65000
old_mmap(0xb7f6d000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) =3D 0xb7f6d000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/lib/libiw.so.28", O_RDONLY)                =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300\25"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D814477,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D48, st_size=3D23228, st_atime=3D2006/08/28-00:34:02,
st_mtime=3D2006/02/09-15:38:09, st_ctime=3D2006/07/05-21:19:53}) =3D 0
old_mmap(NULL, 26188, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f5e000
old_mmap(0xb7f64000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) =3D 0xb7f64000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libnl.so.1", O_RDONLY)             =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\236"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D831039,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D368, st_size=3D180452, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/03/22-05:46:12, st_ctime=3D2006/03/29-09:41:12}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7f5d000
old_mmap(NULL, 179340, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f31000
old_mmap(0xb7f5b000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2a000) =3D 0xb7f5b000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libgthread-2.0.so.0", O_RDONLY)    =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300\21"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D832000,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D32, st_size=3D13324, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/02-09:45:59, st_ctime=3D2006/08/16-18:51:12}) =3D 0
old_mmap(NULL, 16276, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f2d000
old_mmap(0xb7f30000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) =3D 0xb7f30000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/lib/tls/i686/cmov/libpthread.so.0", O_RDONLY) =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0`H\0\000"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D815545,
st_mode=3DS_IFREG|0755, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D184, st_size=3D86580, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/21-11:46:52, st_ctime=3D2006/07/05-21:43:08}) =3D 0
old_mmap(NULL, 71064, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f1b000
old_mmap(0xb7f2a000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe000) =3D 0xb7f2a000
old_mmap(0xb7f2b000, 5528, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7f2b000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libnm-util.so.0", O_RDONLY)        =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\33\0"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D836284,
st_mode=3DS_IFREG|0755, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D200, st_size=3D97043, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/25-14:05:55, st_ctime=3D2006/06/25-14:05:55}) =3D 0
old_mmap(NULL, 39188, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7f11000
old_mmap(0xb7f1a000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) =3D 0xb7f1a000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libdbus-glib-1.so.2", O_RDONLY)    =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0 g\0\000"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D830862,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D216, st_size=3D103004, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/15-12:44:02, st_ctime=3D2006/07/05-21:10:26}) =3D 0
old_mmap(NULL, 106172, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7ef7000
old_mmap(0xb7f10000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x18000) =3D 0xb7f10000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libdbus-1.so.2", O_RDONLY)         =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000J\0\000"...,
512) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D832018,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D448, st_size=3D225236, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/15-12:44:00, st_ctime=3D2006/07/05-21:10:28}) =3D 0
old_mmap(NULL, 224468, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7ec0000
old_mmap(0xb7ef6000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x36000) =3D 0xb7ef6000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libglib-2.0.so.0", O_RDONLY)       =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0000\305"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D831676,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D1056, st_size=3D535424, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/02-09:45:59, st_ctime=3D2006/08/16-18:51:12}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7ebf000
old_mmap(NULL, 539020, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7e3b000
old_mmap(0xb7ebe000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x82000) =3D 0xb7ebe000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libgcrypt.so.11", O_RDONLY)        =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\340>\0"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D833141,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D616, st_size=3D310348, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2005/10/28-02:16:56, st_ctime=3D2006/03/11-16:54:15}) =3D 0
old_mmap(NULL, 309868, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7def000
old_mmap(0xb7e36000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x47000) =3D 0xb7e36000
mprotect(0xbfe39000, 4096, PROT_READ|PROT_WRITE|PROT_EXEC|PROT_GROWSDOW=
N) =3D 0
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/lib/tls/i686/cmov/libnsl.so.1", O_RDONLY)  =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\0005\0"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D815095,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D160, st_size=3D77176, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/21-11:46:52, st_ctime=3D2006/07/05-21:43:08}) =3D 0
old_mmap(NULL, 84384, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7dda000
old_mmap(0xb7dec000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12000) =3D 0xb7dec000
old_mmap(0xb7ded000, 6560, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7ded000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libgpg-error.so.0", O_RDONLY)      =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320\5\0"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D325813,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D24, st_size=3D10292, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2005/10/24-20:25:04, st_ctime=3D2006/07/05-21:10:57}) =3D 0
old_mmap(NULL, 13304, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7dd6000
old_mmap(0xb7dd9000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) =3D 0xb7dd9000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/lib/tls/i686/cmov/libc.so.6", O_RDONLY)    =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\220O\1"..., 51=
2) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D814862,
st_mode=3DS_IFREG|0755, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D2416, st_size=3D1232784, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/21-11:46:52, st_ctime=3D2006/07/05-21:43:08}) =3D 0
old_mmap(NULL, 1238972, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7ca7000
old_mmap(0xb7dcc000, 28672, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x125000) =3D 0xb7dcc000
old_mmap(0xb7dd3000, 10172, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7dd3000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/usr/lib/libgobject-2.0.so.0", O_RDONLY)    =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0@j\0\000"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D831688,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D456, st_size=3D229092, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/02-09:45:59, st_ctime=3D2006/08/16-18:51:12}) =3D 0
old_mmap(NULL, 229316, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7c6f000
old_mmap(0xb7ca6000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x37000) =3D 0xb7ca6000
close(3)                                          =3D 0
access("/etc/ld.so.nohwcap", F_OK)                =3D -1 ENOENT (No suc=
h
file or directory)
open("/lib/tls/i686/cmov/libm.so.6", O_RDONLY)    =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0@3\0\000"..., 5=
12) =3D 512
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D815063,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D280, st_size=3D136368, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/05/21-11:46:52, st_ctime=3D2006/07/05-21:43:08}) =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7c6e000
old_mmap(NULL, 138800, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3, 0) =3D 0xb7c4c000
old_mmap(0xb7c6d000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x20000) =3D 0xb7c6d000
close(3)                                          =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) =3D 0xb7c4b000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7c4b6c0,
limit:1048575, seg_32bit:1, contents:0, read_exec_only:0,
limit_in_pages:1, seg_not_present:0, useable:1}) =3D 0
munmap(0xb7f6e000, 102666)                        =3D 0
set_tid_address(0xb7c4b708)                       =3D 5945
rt_sigaction(SIGRTMIN, {0xb7f1f3b0, [], SA_SIGINFO}, NULL, 8) =3D 0
rt_sigaction(SIGRT_1, {0xb7f1f430, [], SA_RESTART|SA_SIGINFO}, NULL, 8)=
 =3D 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) =3D 0
getrlimit(RLIMIT_STACK, {rlim_cur=3D8192*1024, rlim_max=3DRLIM_INFINITY=
}) =3D 0
_sysctl({{CTL_KERN, KERN_VERSION}, 2, 0xbfe39cac, 32, (nil), 0}) =3D 0
brk(0)                                            =3D 0x808b000
brk(0x80ac000)                                    =3D 0x80ac000
open("/proc/net/psched", O_RDONLY)                =3D -1 ENOENT (No suc=
h
file or directory)
getuid32()                                        =3D 0
clone(Process 5946 attached
child_stack=3D0, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHL=
D,
child_tidptr=3D0xb7c4b708) =3D 5946
[pid  5945] exit_group(0)                         =3D ?
setsid()                                          =3D 5946
chdir("/")                                        =3D 0
open("/dev/null", O_RDWR)                         =3D 3
fstat64(3, {st_dev=3Dmakedev(0, 16), st_ino=3D615, st_mode=3DS_IFCHR|06=
66,
st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0,
st_rdev=3Dmakedev(1, 3), st_atime=3D2006/07/05-23:56:34,
st_mtime=3D2006/05/22-07:25:23, st_ctime=3D2006/08/28-00:31:47}) =3D 0
dup2(3, 0)                                        =3D 0
dup2(3, 1)                                        =3D 1
dup2(3, 2)                                        =3D 2
close(3)                                          =3D 0
open("/var/run/NetworkManager/NetworkManager.pid",
O_WRONLY|O_CREAT|O_TRUNC, 0644) =3D -1 ENOENT (No such file or
directory)
gettimeofday({1156750443, 137247}, NULL)          =3D 0
open("/usr/lib/charset.alias", O_RDONLY|O_LARGEFILE) =3D -1 ENOENT (No
such file or directory)
open("/usr/lib/gconv/gconv-modules.cache", O_RDONLY) =3D -1 ENOENT (No
such file or directory)
open("/usr/lib/gconv/gconv-modules", O_RDONLY)    =3D 3
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D839066,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D96, st_size=3D45568, st_atime=3D2006/08/28-00:33:08,
st_mtime=3D2006/05/21-11:31:25, st_ctime=3D2006/07/05-21:41:32}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0xb7f87000
read(3, "# GNU libc iconv configuration.\n"..., 4096) =3D 4096
read(3, "lias\tJS//\t\t\tJUS_I.B1.002//\nalias"..., 4096) =3D 4096
read(3, "ule\tINTERNAL\t\tISO-8859-3//\t\tISO8"..., 4096) =3D 4096
read(3, "lias\tISO-IR-199//\t\tISO-8859-14//"..., 4096) =3D 4096
read(3, "\t\tto\t\t\tmodule\t\tcost\nalias\tCSEBCD"..., 4096) =3D 4096
read(3, "ule\t\tcost\nalias\tCP284//\t\t\tIBM284"..., 4096) =3D 4096
read(3, "lias\tCP864//\t\t\tIBM864//\nalias\t86"..., 4096) =3D 4096
read(3, "module\tIBM937//\t\tINTERNAL\t\tIBM93"..., 4096) =3D 4096
read(3, "\tEUC-JP//\nalias\tUJIS//\t\t\tEUC-JP/"..., 4096) =3D 4096
read(3, "module\t\tcost\nalias\tISO-IR-143//\t"..., 4096) =3D 4096
read(3, "-BOX//\nmodule\tISO_10367-BOX//\t\tI"..., 4096) =3D 4096
read(3, "module\tINTERNAL\t\tEUC-JISX0213//\t"..., 4096) =3D 512
read(3, "", 4096)                                 =3D 0
close(3)                                          =3D 0
munmap(0xb7f87000, 4096)                          =3D 0
futex(0xb7dd2c4c, FUTEX_WAKE, 2147483647)         =3D 0
write(2, "\n** (process:5946): WARNING **: "..., 147) =3D 147
sched_getparam(5946, { 0 })                       =3D 0
sched_getscheduler(5946)                          =3D 0 (SCHED_OTHER)
sched_get_priority_min(SCHED_OTHER)               =3D 0
sched_get_priority_max(SCHED_OTHER)               =3D 0
sched_get_priority_max(SCHED_OTHER)               =3D 0
open("/usr/share/locale/locale.alias", O_RDONLY|O_LARGEFILE) =3D 3
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D195499,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D2586, st_atime=3D2006/08/28-00:33:08,
st_mtime=3D2003/12/03-23:57:47, st_ctime=3D2006/03/11-16:53:02}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0xb7f87000
read(3, "# Locale name alias data base.\n#"..., 4096) =3D 2586
read(3, "", 4096)                                 =3D 0
close(3)                                          =3D 0
munmap(0xb7f87000, 4096)                          =3D 0
rt_sigaction(SIGTERM, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGINT, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGILL, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGBUS, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGFPE, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGHUP, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGSEGV, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGABRT, {0x806adf5, [], 0}, NULL, 8) =3D 0
rt_sigaction(SIGUSR1, {0x806adf5, [], 0}, NULL, 8) =3D 0
time([1156750443])                                =3D 1156750443
open("/etc/localtime", O_RDONLY)                  =3D 3
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:02,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
fstat64(3, {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:02,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0xb7f87000
read(3, "TZif\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\4\0\0\0\4\0"...,
4096) =3D 1037
close(3)                                          =3D 0
munmap(0xb7f87000, 4096)                          =3D 0
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)                    =3D 3
fcntl64(3, F_SETFD, FD_CLOEXEC)                   =3D 0
connect(3, {sa_family=3DAF_FILE, path=3D"/dev/log"}, 16) =3D 0
send(3, "<29>Aug 28 00:34:03 NetworkManag"..., 66, MSG_NOSIGNAL) =3D 66
pipe([4, 5])                                      =3D 0
pipe([6, 7])                                      =3D 0
fstat64(6, {st_dev=3Dmakedev(0, 5), st_ino=3D15423, st_mode=3DS_IFIFO|0=
600,
st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0,
st_size=3D0, st_atime=3D2006/08/28-00:34:03, st_mtime=3D2006/08/28-00:3=
4:03,
st_ctime=3D2006/08/28-00:34:03}) =3D 0
fcntl64(6, F_GETFL)                               =3D 0 (flags O_RDONLY=
)
socket(PF_FILE, SOCK_STREAM, 0)                   =3D 8
connect(8, {sa_family=3DAF_FILE, path=3D"/var/run/dbus/system_bus_socke=
t"}, 33) =3D 0
fcntl64(8, F_GETFL)                               =3D 0x2 (flags O_RDWR=
)
fcntl64(8, F_SETFL, O_RDWR|O_NONBLOCK)            =3D 0
fcntl64(8, F_GETFD)                               =3D 0
fcntl64(8, F_SETFD, FD_CLOEXEC)                   =3D 0
getuid32()                                        =3D 0
rt_sigaction(SIGPIPE, {SIG_IGN}, {SIG_DFL}, 8)    =3D 0
poll([{fd=3D8, events=3DPOLLOUT, revents=3DPOLLOUT}], 1, 0) =3D 1
write(8, "\0", 1)                                 =3D 1
write(8, "AUTH EXTERNAL 30\r\n", 18)              =3D 18
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
read(8, "OK 189cf2449e2a8bf05c7bd95f1438e"..., 2048) =3D 37
poll([{fd=3D8, events=3DPOLLOUT, revents=3DPOLLOUT}], 1, -1) =3D 1
write(8, "BEGIN\r\n", 7)                          =3D 7
poll([{fd=3D8, events=3DPOLLIN|POLLOUT, revents=3DPOLLOUT}], 1, -1) =3D=
 1
writev(8, [{"l\1\0\1\0\0\0\0\1\0\0\0n\0\0\0\1\1o\0\25\0\0\0/org/fre"...=
,
128}, {"", 0}], 2) =3D 128
gettimeofday({1156750443, 145213}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\t\0\0\0\1\0\0\0=3D\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"...,
2048) =3D 258
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
fstat64(8, {st_dev=3Dmakedev(0, 4), st_ino=3D15424, st_mode=3DS_IFSOCK|=
0777,
st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksize=3D4096, st_blocks=3D0,
st_size=3D0, st_atime=3D0, st_mtime=3D0, st_ctime=3D0}) =3D 0
fcntl64(8, F_GETFL)                               =3D 0x802 (flags
O_RDWR|O_NONBLOCK)
writev(8, [{"l\1\1\1Q\0\0\0\2\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/f"...=
,
144}, {"L\0\0\0type=3D\'signal\',interface=3D\'org"..., 81}], 2) =3D 22=
5
gettimeofday({1156750443, 145869}, NULL)          =3D 0
writev(8, [{"l\1\0\1\'\0\0\0\3\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/"...=
,
144}, {"\"\0\0\0org.freedesktop.NetworkManag"..., 39}], 2) =3D 183
gettimeofday({1156750443, 146088}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\0\0\0\0\3\0\0\0005\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"...,
2048) =3D 291
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 146330}, NULL)          =3D 0
writev(8, [{"l\1\0\1(\0\0\0\4\0\0\0\200\0\0\0\1\1o\0\25\0\0\0/org/f"...=
,
144}, {"\36\0\0\0org.freedesktop.NetworkManag"..., 40}], 2) =3D 184
gettimeofday({1156750443, 146780}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\4\1\0015\0\0\0\5\0\0\0\211\0\0\0\1\1o\0\25\0\0\0/org"..., 20=
48) =3D 492
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
brk(0x80cd000)                                    =3D 0x80cd000
time([1156750443])                                =3D 1156750443
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
stat64("/etc/localtime", {st_dev=3Dmakedev(3, 10), st_ino=3D896732,
st_mode=3DS_IFREG|0644, st_nlink=3D1, st_uid=3D0, st_gid=3D0, st_blksiz=
e=3D4096,
st_blocks=3D8, st_size=3D1037, st_atime=3D2006/08/28-00:34:03,
st_mtime=3D2006/06/22-00:10:06, st_ctime=3D2006/06/25-23:55:00}) =3D 0
brk(0x80cb000)                                    =3D 0x80cb000
send(3, "<28>Aug 28 00:34:03 NetworkManag"..., 96, MSG_NOSIGNAL) =3D 96
brk(0x80ca000)                                    =3D 0x80ca000
writev(8, [{"l\1\1\1=3D\0\0\0\5\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/f".=
=2E.,
144}, {"8\0\0\0type=3D\'signal\',interface=3D\'org"..., 61}], 2) =3D 20=
5
open("/etc/NetworkManager/VPN",
O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) =3D -1 ENOENT (No such fil=
e
or directory)
gettimeofday({1156750443, 168887}, NULL)          =3D 0
writev(8, [{"l\1\0\1\24\0\0\0\6\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org"...=
,
144}, {"\17\0\0\0com.redhat.dhcp\0", 20}], 2) =3D 164
gettimeofday({1156750443, 169099}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\0\0\0\0\10\0\0\0005\0\0\0\6\1s\0\4\0\0\0:1.3\0"..., 20=
48) =3D 156
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 169291}, NULL)          =3D 0
writev(8, [{"l\1\0\1\24\0\0\0\7\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org"...=
,
144}, {"\17\0\0\0com.redhat.dhcp\0", 20}], 2) =3D 164
gettimeofday({1156750443, 169500}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\t\0\0\0\n\0\0\0=3D\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"...,=
 2048) =3D 89
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
writev(8, [{"l\1\1\1B\0\0\0\10\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/"...=
,
144}, {"=3D\0\0\0type=3D\'signal\',interface=3D\'com"..., 66}], 2) =3D =
210
gettimeofday({1156750443, 170042}, NULL)          =3D 0
writev(8, [{"l\1\0\1\25\0\0\0\t\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org"...=
,
144}, {"\20\0\0\0com.redhat.named\0", 21}], 2) =3D 165
gettimeofday({1156750443, 170241}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\0\0\0\0\v\0\0\0005\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"...,
2048) =3D 156
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 170457}, NULL)          =3D 0
writev(8, [{"l\1\0\1\'\0\0\0\n\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/"...=
,
144}, {"\"\0\0\0org.freedesktop.NetworkManag"..., 39}], 2) =3D 183
gettimeofday({1156750443, 170655}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\r\0\0\0=3D\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"...,=
 2048) =3D 84
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 170830}, NULL)          =3D 0
writev(8, [{"l\1\0\1\30\0\0\0\v\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org"...=
,
144}, {"\23\0\0\0org.freedesktop.Hal\0", 24}], 2) =3D 168
gettimeofday({1156750443, 171023}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\t\0\0\0\16\0\0\0=3D\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"..., =
2048) =3D 89
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 171225}, NULL)          =3D 0
writev(8, [{"l\1\0\1\30\0\0\0\f\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org"...=
,
144}, {"\23\0\0\0org.freedesktop.Hal\0", 24}], 2) =3D 168
gettimeofday({1156750443, 171433}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\17\0\0\0=3D\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"..., =
2048) =3D 84
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 171615}, NULL)          =3D 0
writev(8, [{"l\1\0\1{\0\0\0\r\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/f"...=
,
144}, {"v\0\0\0type=3D\'signal\',interface=3D\'org"..., 123}], 2) =3D 2=
67
gettimeofday({1156750443, 171812}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\0\0\0\0\20\0\0\0005\0\0\0\6\1s\0\4\0\0\0:1.3\0"..., 20=
48) =3D 72
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 171989}, NULL)          =3D 0
writev(8, [{"l\1\0\1V\0\0\0\16\0\0\0\177\0\0\0\1\1o\0\25\0\0\0/org/"...=
,
144}, {"Q\0\0\0type=3D\'signal\',interface=3D\'org"..., 86}], 2) =3D 23=
0
gettimeofday({1156750443, 172182}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\0\0\0\0\21\0\0\0005\0\0\0\6\1s\0\4\0\0\0:1.3\0"..., 20=
48) =3D 72
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 172363}, NULL)          =3D 0
writev(8, [{"l\1\0\1\10\0\0\0\17\0\0\0\227\0\0\0\1\1o\0\34\0\0\0/or"...=
,
168}, {"\3\0\0\0net\0", 8}], 2) =3D 176
gettimeofday({1156750443, 172834}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1s\0\0\0\4\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 20=
48) =3D 179
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 173051}, NULL)          =3D 0
writev(8, [{"l\1\0\1\22\0\0\0\20\0\0\0\247\0\0\0\1\1o\0002\0\0\0/or"...=
,
184}, {"\r\0\0\0net.interface\0", 18}], 2) =3D 202
gettimeofday({1156750443, 173353}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\5\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 2=
048) =3D 68
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 173543}, NULL)          =3D 0
writev(8, [{"l\1\0\1\22\0\0\0\21\0\0\0\247\0\0\0\1\1o\0002\0\0\0/or"...=
,
184}, {"\r\0\0\0info.category\0", 18}], 2) =3D 202
gettimeofday({1156750443, 173839}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\6\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 2=
048) =3D 68
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 174018}, NULL)          =3D 0
writev(8, [{"l\1\0\1\22\0\0\0\22\0\0\0\257\0\0\0\1\1o\0002\0\0\0/or"...=
,
192}, {"\r\0\0\0info.category\0", 18}], 2) =3D 210
gettimeofday({1156750443, 174312}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\16\0\0\0\7\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"..., 20=
48) =3D 78
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 174500}, NULL)          =3D 0
writev(8, [{"l\1\0\1\22\0\0\0\23\0\0\0\257\0\0\0\1\1o\0002\0\0\0/or"...=
,
192}, {"\r\0\0\0net.interface\0", 18}], 2) =3D 210
gettimeofday({1156750443, 174795}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\t\0\0\0\10\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0"..., 20=
48) =3D 73
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)           =3D 9
ioctl(9, SIOCGIWNAME, 0xbfe38d8c)                 =3D -1 EINVAL (Invali=
d argument)
close(9)                                          =3D 0
gettimeofday({1156750443, 175128}, NULL)          =3D 0
writev(8, [{"l\1\0\1\30\0\0\0\24\0\0\0\257\0\0\0\1\1o\0002\0\0\0/or"...=
,
192}, {"\23\0\0\0net.physical_device\0", 24}], 2) =3D 216
gettimeofday({1156750443, 175442}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1/\0\0\0\t\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 20=
48) =3D 111
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 175618}, NULL)          =3D 0
writev(8, [{"l\1\0\1\26\0\0\0\25\0\0\0\237\0\0\0\1\1o\0*\0\0\0/org/"...=
,
176}, {"\21\0\0\0info.linux.driver\0", 22}], 2) =3D 198
gettimeofday({1156750443, 175913}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\n\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 2=
048) =3D 68
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 176089}, NULL)          =3D 0
writev(8, [{"l\1\0\1\26\0\0\0\26\0\0\0\247\0\0\0\1\1o\0*\0\0\0/org/"...=
,
184}, {"\21\0\0\0info.linux.driver\0", 22}], 2) =3D 206
gettimeofday({1156750443, 176397}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\f\0\0\0\v\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 2=
048) =3D 76
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
gettimeofday({1156750443, 176579}, NULL)          =3D 0
writev(8, [{"l\1\0\1\30\0\0\0\27\0\0\0\247\0\0\0\1\1o\0002\0\0\0/or"...=
,
184}, {"\23\0\0\0usb.interface.class\0", 24}], 2) =3D 208
gettimeofday({1156750443, 176876}, NULL)          =3D 0
poll([{fd=3D8, events=3DPOLLIN, revents=3DPOLLIN}], 1, 25000) =3D 1
read(8, "l\2\1\1\4\0\0\0\f\0\0\0-\0\0\0\6\1s\0\4\0\0\0:1.3\0\0\0"..., 2=
048) =3D 68
read(8, 0x80a7e70, 2048)                          =3D -1 EAGAIN
(Resource temporarily unavailable)
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)           =3D 9
ioctl(9, SIOCETHTOOL, 0xbfe38d2c)                 =3D 0
close(9)                                          =3D 0
pipe([9, 10])                                     =3D 0
time(NULL)                                        =3D 1156750443
socket(PF_NETLINK, SOCK_RAW, 0)                   =3D 11
setsockopt(11, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(11, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(11, {sa_family=3DAF_NETLINK, pid=3D-1228925126, groups=3D00000000}=
, 12) =3D 0
getsockname(11, {sa_family=3DAF_NETLINK, pid=3D-1228925126,
groups=3D00000000}, [12]) =3D 0
sendmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\22\0\5\3k\234\362D:\27\300\266\0\240\261\365"=
=2E..,
20}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\364\0\0\0\20\0\2\0k\234\362D:\27\300\266\0\0\4\3\1\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, MSG_PEEK) =3D 980
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\364\0\0\0\20\0\2\0k\234\362D:\27\300\266\0\0\4\3\1\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 980
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0k\234\362D:\27\300\266\0\0\0\0\0\0\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, MSG_PEEK) =3D 20
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0k\234\362D:\27\300\266\0\0\0\0\0\0\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
sendmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\22\0\5\3l\234\362D:\27\300\266\0\240\261\365"=
=2E..,
20}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\364\0\0\0\20\0\2\0l\234\362D:\27\300\266\0\0\4\3\1\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, MSG_PEEK) =3D 980
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\364\0\0\0\20\0\2\0l\234\362D:\27\300\266\0\0\4\3\1\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 980
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0l\234\362D:\27\300\266\0\0\0\0\0\0\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, MSG_PEEK) =3D 20
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0l\234\362D:\27\300\266\0\0\0\0\0\0\0\0=
"...,
4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
sendmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000}, msg_iov(1)=3D[{"
\0\0\0\23\0\5\0m\234\362D:\27\300\266\0\0\0\0\2\0\0\0"..., 32}],
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 32
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0m\234\362D:\27\300\266\0\0\0\0
\0\0\0\23"..., 4096}], msg_controllen=3D0, msg_flags=3D0}, MSG_PEEK) =3D=
 36
recvmsg(11, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0m\234\362D:\27\300\266\0\0\0\0
\0\0\0\23"..., 4096}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 36
close(11)                                         =3D 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)           =3D 11
ioctl(11, SIOCGIFHWADDR, {ifr_name=3D"eth0", ???})  =3D -1 ENODEV (No s=
uch device)
close(11)                                         =3D 0
nanosleep({0, 5000000}, {0, 3219361032})          =3D 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)           =3D 11
ioctl(11, SIOCGIFFLAGS, {ifr_name=3D"eth0", ???})   =3D -1 ENODEV (No s=
uch device)
close(11)                                         =3D 0
