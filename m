From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: regression: ip r change mss doesn't work in 2.6.38-git14
Date: Thu, 24 Mar 2011 16:08:36 +0100
Message-ID: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After fixing the display issue thanks to Chris Wilson, I now have
another problem
 (which didn't exist in 2.6.38-git2); most websites outside of my DSL l=
ink don't
 work properly (connection packet goes through, but the page load times=
 out
 within Firefox) unless I do

ip r change default via 192.168.1.1 dev eth1 advmss 1400

This however doesn't change advmss anymore:

[root@duff ~]# ip r
default via 192.168.1.1 dev eth1
169.254.0.0/16 dev eth1  scope link  metric 1004
192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.8
[root@duff ~]# ip r change default via 192.168.1.1 dev eth1 advmss 1400
[root@duff ~]# ip r
default via 192.168.1.1 dev eth1
169.254.0.0/16 dev eth1  scope link  metric 1004
192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.8


strace of this operation doesn't appear to show errors in userspace,
 which is btw:

[root@duff ~]# ip -V
ip utility, iproute2-ss100804
[root@duff ~]# rpm -qf /sbin/ip
iproute-2.6.35-6.fc14.x86_64


execve("/sbin/ip", ["ip", "r", "change", "default", "via",
"192.168.1.1", "dev", "eth1", "advmss", "1400"], [/* 23 vars */]) =3D 0
brk(0)                                  =3D 0x2461000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f79c8d1c000
access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT (No such file or =
directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D101259, ...}) =3D 0
mmap(NULL, 101259, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x7f79c8d03000
close(3)                                =3D 0
open("/lib64/libresolv.so.2", O_RDONLY) =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p8`12\0\0\0"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D113832, ...}) =3D 0
mmap(0x3231600000, 2202280, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x3231600000
mprotect(0x3231617000, 2093056, PROT_NONE) =3D 0
mmap(0x3231816000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) =3D 0x3231816000
mmap(0x3231818000, 6824, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x3231818000
close(3)                                =3D 0
open("/lib64/libdl.so.2", O_RDONLY)     =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\r
/2\0\0\0"..., 832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D22536, ...}) =3D 0
mmap(0x322f200000, 2109720, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x322f200000
mprotect(0x322f202000, 2097152, PROT_NONE) =3D 0
mmap(0x322f402000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) =3D 0x322f402000
close(3)                                =3D 0
open("/lib64/libgcc_s.so.1", O_RDONLY)  =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360(
02\0\0\0"..., 832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D89760, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f79c8d02000
mmap(0x3230200000, 2183032, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x3230200000
mprotect(0x3230215000, 2093056, PROT_NONE) =3D 0
mmap(0x3230414000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14000) =3D 0x3230414000
close(3)                                =3D 0
open("/lib64/libc.so.6", O_RDONLY)      =3D 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\357\241.2\0\0\=
0"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D1956608, ...}) =3D 0
mmap(0x322ea00000, 3781816, PROT_READ|PROT_EXEC,
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0x322ea00000
mprotect(0x322eb91000, 2097152, PROT_NONE) =3D 0
mmap(0x322ed91000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x191000) =3D 0x322ed91000
mmap(0x322ed96000, 21688, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x322ed96000
close(3)                                =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f79c8d01000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f79c8cff000
arch_prctl(ARCH_SET_FS, 0x7f79c8cff720) =3D 0
mprotect(0x3231816000, 4096, PROT_READ) =3D 0
mprotect(0x322f402000, 4096, PROT_READ) =3D 0
mprotect(0x322ed91000, 16384, PROT_READ) =3D 0
mprotect(0x322e81e000, 4096, PROT_READ) =3D 0
munmap(0x7f79c8d03000, 101259)          =3D 0
socket(PF_NETLINK, SOCK_RAW, 0)         =3D 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) =3D 0
bind(3, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D 0
getsockname(3, {sa_family=3DAF_NETLINK, pid=3D4336, groups=3D00000000},=
 [12]) =3D 0
sendto(3, "\24\0\0\0\22\0\1\3\330]\213M\0\0\0\0\0\0\0\0", 20, 0, NULL, =
0) =3D 20
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\344\3\0\0\20\0\2\0\330]\213M\360\20\0\0\0\0\4\3\1\0\0\=
0I\0\1\0\0\0\0\0"...,
16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 3020
brk(0)                                  =3D 0x2461000
brk(0x2482000)                          =3D 0x2482000
brk(0)                                  =3D 0x2482000
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0\330]\213M\360\20\0\0\0\0\0\0\1\0\0\0I=
\0\1\0\0\0\0\0"...,
16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20
sendmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"8\0\0\0\30\0\5\1\331]\213M\0\0\0\0\2\0\0\0\376\3\0\1\0\=
0\0\0\10\0\5\0"...,
56}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 56
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0\331]\213M\360\20\0\0\0\0\0\0008\0\0\0\3=
0\0\5\1\331]\213M"...,
16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 36
exit_group(0)                           =3D ?


Thanks in advance,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
