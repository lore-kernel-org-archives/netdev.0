From: Filippo Zangheri <filippo.zangheri@yahoo.it>
Subject: OT: PJSIP: Segmentation fault
Date: Fri, 04 Jul 2008 12:14:52 +0200
Message-ID: <486DF81C.8000008@yahoo.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDBA5D0F2D439BC3EC8B1FE8E"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n2.bullet.mail.re3.yahoo.com ([68.142.237.109]:32231 "HELO
	n2.bullet.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751029AbYGDKPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 06:15:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDBA5D0F2D439BC3EC8B1FE8E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi all,

I'm trying to test pjsip-0.9.0 on a Debian with vanilla kernel 2.6.25.9
(without IPv6 support).

I'm posting my problem to this mailing list in the hope that some kernel
guru helps me shed a little light on the problem I'm experiencing, which
- I think - is closely related to Linux network internals.

I'm getting a Segmentation fault but I'm not able to determine the cause.=

Avoiding to call pj_enum_ip_interface() completely solves the problem.

Briefly:

I've double-checked the parameters passed to that function; I've printed
messages to standard output to determine where the error occurrs, but it
seems that the cause is not inside the function...

Can you spot anything wrong in the following strace log?

=3D=3D=3D STRACE LOG ('strace -rif -o strace.log ./stateful_proxy-i686-pc=
-linux-gnu') =3D=3D=3D

15191 0.000000 [b7f8e424] execve("./stateful_proxy-i686-pc-linux-gnu", ["=
=2E/stateful_proxy-i686-pc-linux-g"...], [/* 35 vars */]) =3D 0
15191 0.000248 [b7efc9ed] uname({sys=3D"Linux", node=3D"asus-laptop", ...=
}) =3D 0
15191 0.000122 [b7efbedb] brk(0) =3D 0x8080000
15191 0.000044 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000059 [b7efc933] mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ee9000
15191 0.000038 [b7efc781] access("/etc/ld.so.preload", R_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000051 [b7efc644] open("/etc/ld.so.cache", O_RDONLY) =3D 3
15191 0.000039 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D7=
1336, ...}) =3D 0
15191 0.000066 [b7efc933] mmap2(NULL, 71336, PROT_READ, MAP_PRIVATE, 3, 0=
) =3D 0xb7ed7000
15191 0.000030 [b7efc67d] close(3) =3D 0
15191 0.000029 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000049 [b7efc644] open("/lib/tls/i686/cmov/libm.so.6", O_RDONLY) =
=3D 3
15191 0.000047 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0`3\0\000"..., 512) =3D 512
15191 0.000049 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D1=
45136, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 147584, PROT_READ|PROT_EXEC, MAP_PR=
IVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7eb2000
15191 0.000036 [b7efc933] mmap2(0xb7ed5000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22) =3D 0xb7ed5000
15191 0.000046 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000041 [b7efc644] open("/lib/tls/i686/cmov/libnsl.so.1", O_RDONLY=
) =3D 3
15191 0.000048 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0p5\0\000"..., 512) =3D 512
15191 0.000047 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D7=
6548, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 87808, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 3, 0) =3D 0xb7e9c000
15191 0.000034 [b7efc933] mmap2(0xb7eae000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x11) =3D 0xb7eae000
15191 0.000043 [b7efc933] mmap2(0xb7eb0000, 5888, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7eb0000
15191 0.000038 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000043 [b7efc644] open("/lib/tls/i686/cmov/librt.so.1", O_RDONLY)=
 =3D 3
15191 0.000046 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0000\36\0"..., 512) =3D 512
15191 0.000048 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D3=
0612, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7e9b000
15191 0.000037 [b7efc933] mmap2(NULL, 33384, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 3, 0) =3D 0xb7e92000
15191 0.000034 [b7efc933] mmap2(0xb7e99000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6) =3D 0xb7e99000
15191 0.000047 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000041 [b7efc644] open("/lib/tls/i686/cmov/libpthread.so.0", O_RD=
ONLY) =3D 3
15191 0.000047 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\240H\0"..., 512) =3D 512
15191 0.000047 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0755, st_size=3D8=
9370, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 70104, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 3, 0) =3D 0xb7e80000
15191 0.000048 [b7efc933] mmap2(0xb7e8e000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe) =3D 0xb7e8e000
15191 0.000043 [b7efc933] mmap2(0xb7e90000, 4568, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7e90000
15191 0.000039 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000053 [b7efc644] open("/usr/lib/i686/cmov/libssl.so.0.9.8", O_RD=
ONLY) =3D 3
15191 0.000045 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\220\255"..., 512) =3D 512
15191 0.000050 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D2=
53120, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 256084, PROT_READ|PROT_EXEC, MAP_PR=
IVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7e41000
15191 0.000034 [b7efc933] mmap2(0xb7e7c000, 16384, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3a) =3D 0xb7e7c000
15191 0.000046 [b7efc67d] close(3) =3D 0
15191 0.000032 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000045 [b7efc644] open("/usr/lib/i686/cmov/libcrypto.so.0.9.8", O=
_RDONLY) =3D 3
15191 0.000045 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\300Y\3"..., 512) =3D 512
15191 0.000047 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D1=
270520, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 1282904, PROT_READ|PROT_EXEC, MAP_P=
RIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7d07000
15191 0.000035 [b7efc933] mmap2(0xb7e29000, 81920, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x122) =3D 0xb7e29000
15191 0.000053 [b7efc933] mmap2(0xb7e3d000, 13144, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7e3d000
15191 0.000040 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000043 [b7efc644] open("/lib/tls/i686/cmov/libc.so.6", O_RDONLY) =
=3D 3
15191 0.000043 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\240O\1"..., 512) =3D 512
15191 0.000045 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D1=
241392, ...}) =3D 0
15191 0.000057 [b7efc933] mmap2(NULL, 1247388, PROT_READ|PROT_EXEC, MAP_P=
RIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7bd6000
15191 0.000034 [b7efc933] mmap2(0xb7cfd000, 28672, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x127) =3D 0xb7cfd000
15191 0.000043 [b7efc933] mmap2(0xb7d04000, 10396, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7d04000
15191 0.000038 [b7efc67d] close(3) =3D 0
15191 0.000041 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000041 [b7efc644] open("/lib/tls/i686/cmov/libdl.so.2", O_RDONLY)=
 =3D 3
15191 0.000045 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\20\f\0"..., 512) =3D 512
15191 0.000046 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D9=
592, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7bd5000
15191 0.000039 [b7efc933] mmap2(NULL, 12404, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 3, 0) =3D 0xb7bd1000
15191 0.000034 [b7efc933] mmap2(0xb7bd3000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1) =3D 0xb7bd3000
15191 0.000045 [b7efc67d] close(3) =3D 0
15191 0.000031 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000041 [b7efc644] open("/usr/lib/libz.so.1", O_RDONLY) =3D 3
15191 0.000044 [b7efc6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\340\26"..., 512) =3D 512
15191 0.000047 [b7efc60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D7=
8500, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 81456, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 3, 0) =3D 0xb7bbd000
15191 0.000035 [b7efc933] mmap2(0xb7bd0000, 4096, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12) =3D 0xb7bd0000
15191 0.000040 [b7efc67d] close(3) =3D 0
15191 0.000071 [b7efc933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7bbc000
15191 0.000278 [b7efc9b4] mprotect(0xb7cfd000, 20480, PROT_READ) =3D 0
15191 0.000280 [b7eeec11] set_thread_area({entry_number:-1 -> 6, base_add=
r:0xb7bbc6c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, l=
imit_in_pages:1, seg_not_present:0, useable:1}) =3D 0
15191 0.000057 [b7efc971] munmap(0xb7ed7000, 71336) =3D 0
15191 0.000038 [b7eeb424] set_tid_address(0xb7bbc708) =3D 15191
15191 0.000039 [b7eeb424] rt_sigaction(SIGRTMIN, {0xb7e844c0, [], SA_SIGI=
NFO}, NULL, 8) =3D 0
15191 0.000046 [b7eeb424] rt_sigaction(SIGRT_1, {0xb7e84420, [], SA_RESTA=
RT|SA_SIGINFO}, NULL, 8) =3D 0
15191 0.000038 [b7eeb424] rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL,=
 8) =3D 0
15191 0.000039 [b7eeb424] getrlimit(RLIMIT_STACK, {rlim_cur=3D8192*1024, =
rlim_max=3DRLIM_INFINITY}) =3D 0
15191 0.000058 [b7eeb424] uname({sys=3D"Linux", node=3D"asus-laptop", ...=
}) =3D 0
15191 0.000238 [b7eeb424] gettimeofday({1215118640, 424400}, NULL) =3D 0
15191 0.000036 [b7eeb424] gettimeofday({1215118640, 424433}, NULL) =3D 0
15191 0.000069 [b7eeb424] brk(0) =3D 0x8080000
15191 0.000027 [b7eeb424] brk(0x80a1000) =3D 0x80a1000
15191 0.000042 [b7eeb424] open("/etc/localtime", O_RDONLY) =3D 3
15191 0.000043 [b7eeb424] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D2=
652, ...}) =3D 0
15191 0.000061 [b7eeb424] fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D2=
652, ...}) =3D 0
15191 0.000057 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ee8000
15191 0.000033 [b7eeb424] read(3, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\=
0\0\6\0\0\0\6\0\0"..., 4096) =3D 2652
15191 0.000066 [b7eeb424] close(3) =3D 0
15191 0.000028 [b7eeb424] munmap(0xb7ee8000, 4096) =3D 0
15191 0.000049 [b7eeb424] fstat64(1, {st_mode=3DS_IFCHR|0620, st_rdev=3Dm=
akedev(136, 1), ...}) =3D 0
15191 0.000057 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ee8000
15191 0.000036 [b7eeb424] write(1, " 22:57:20.424 os_core_unix.c pjl"...,=
 71) =3D 71
15191 0.000162 [b7eeb424] uname({sys=3D"Linux", node=3D"asus-laptop", ...=
}) =3D 0
15191 0.000144 [b7eeb424] mmap2(NULL, 266240, PROT_READ|PROT_WRITE, MAP_P=
RIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7b7b000
15191 0.000039 [b7eeb424] mmap2(NULL, 266240, PROT_READ|PROT_WRITE, MAP_P=
RIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7b3a000
15191 0.000344 [b7eeb424] gettimeofday({1215118640, 425691}, NULL) =3D 0
15191 0.000038 [b7eeb424] write(1, " 22:57:20.425 pjlib sel"..., 69) =3D =
69
15191 0.000048 [b7eeb424] gettimeofday({1215118640, 425777}, NULL) =3D 0
15191 0.000037 [b7eeb424] write(1, " 22:57:20.425 sip_endpoint.c Mod"...,=
 63) =3D 63
15191 0.000044 [b7eeb424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
15191 0.000114 [b7eeb424] gettimeofday({1215118640, 425972}, NULL) =3D 0
15191 0.000037 [b7eeb424] write(1, " 22:57:20.425 sip_endpoint.c Mod"...,=
 63) =3D 63
15191 0.000042 [b7eeb424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
15191 0.000031 [b7eeb424] gettimeofday({1215118640, 426080}, NULL) =3D 0
15191 0.000034 [b7eeb424] write(1, " 22:57:20.426 sip_endpoint.c Mod"...,=
 67) =3D 67
15191 0.000041 [b7eeb424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
15191 0.000037 [b7eeb424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 3
15191 0.000049 [b7eeb424] bind(3, {sa_family=3DAF_INET, sin_port=3Dhtons(=
5060), sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
15191 0.000053 [b7eeb424] getsockname(3, {sa_family=3DAF_INET, sin_port=3D=
htons(5060), sin_addr=3Dinet_addr("0.0.0.0")}, [16]) =3D 0
15191 0.000094 [b7eeb424] gettimeofday({1215118640, 426390}, NULL) =3D 0
15191 0.000037 [b7eeb424] open("/etc/resolv.conf", O_RDONLY) =3D 4
15191 0.000047 [b7eeb424] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D4=
6, ...}) =3D 0
15191 0.000057 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ee7000
15191 0.000032 [b7eeb424] read(4, "nameserver 85.37.17.47\nnameserve"...,=
 4096) =3D 46
15191 0.000056 [b7eeb424] read(4, "", 4096) =3D 0
15191 0.000029 [b7eeb424] close(4) =3D 0
15191 0.000028 [b7eeb424] munmap(0xb7ee7000, 4096) =3D 0
15191 0.000032 [b7eeb424] uname({sys=3D"Linux", node=3D"asus-laptop", ...=
}) =3D 0
15191 0.000131 [b7eeb424] socket(PF_FILE, SOCK_STREAM, 0) =3D 4
15191 0.000034 [b7eeb424] fcntl64(4, F_GETFL) =3D 0x2 (flags O_RDWR)
15191 0.000047 [b7eeb424] fcntl64(4, F_SETFL, O_RDWR|O_NONBLOCK) =3D 0
15191 0.000033 [b7eeb424] connect(4, {sa_family=3DAF_FILE, path=3D"/var/r=
un/nscd/socket"}, 110) =3D -1 ENOENT (No such file or directory)
15191 0.000069 [b7eeb424] close(4) =3D 0
15191 0.000035 [b7eeb424] socket(PF_FILE, SOCK_STREAM, 0) =3D 4
15191 0.000031 [b7eeb424] fcntl64(4, F_GETFL) =3D 0x2 (flags O_RDWR)
15191 0.000029 [b7eeb424] fcntl64(4, F_SETFL, O_RDWR|O_NONBLOCK) =3D 0
15191 0.000031 [b7eeb424] connect(4, {sa_family=3DAF_FILE, path=3D"/var/r=
un/nscd/socket"}, 110) =3D -1 ENOENT (No such file or directory)
15191 0.000061 [b7eeb424] close(4) =3D 0
15191 0.000033 [b7eeb424] open("/etc/nsswitch.conf", O_RDONLY) =3D 4
15191 0.000045 [b7eeb424] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D4=
75, ...}) =3D 0
15191 0.000057 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ee7000
15191 0.000031 [b7eeb424] read(4, "# /etc/nsswitch.conf\n#\n# Example"...=
, 4096) =3D 475
15191 0.000062 [b7eeb424] read(4, "", 4096) =3D 0
15191 0.000028 [b7eeb424] close(4) =3D 0
15191 0.000028 [b7eeb424] munmap(0xb7ee7000, 4096) =3D 0
15191 0.000046 [b7efc644] open("/etc/ld.so.cache", O_RDONLY) =3D 4
15191 0.000039 [b7efc60e] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D7=
1336, ...}) =3D 0
15191 0.000056 [b7efc933] mmap2(NULL, 71336, PROT_READ, MAP_PRIVATE, 4, 0=
) =3D 0xb7b28000
15191 0.000034 [b7efc67d] close(4) =3D 0
15191 0.000030 [b7efc781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 ENOEN=
T (No such file or directory)
15191 0.000051 [b7efc644] open("/lib/tls/i686/cmov/libnss_files.so.2", O_=
RDONLY) =3D 4
15191 0.000051 [b7efc6c4] read(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\=
0\1\0\0\0\200\33"..., 512) =3D 512
15191 0.000050 [b7efc60e] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D3=
8372, ...}) =3D 0
15191 0.000057 [b7efc933] mmap2(NULL, 41620, PROT_READ|PROT_EXEC, MAP_PRI=
VATE|MAP_DENYWRITE, 4, 0) =3D 0xb7edd000
15191 0.000036 [b7efc933] mmap2(0xb7ee6000, 8192, PROT_READ|PROT_WRITE, M=
AP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x8) =3D 0xb7ee6000
15191 0.000048 [b7efc67d] close(4) =3D 0
15191 0.000058 [b7efc971] munmap(0xb7b28000, 71336) =3D 0
15191 0.000045 [b7eeb424] open("/etc/host.conf", O_RDONLY) =3D 4
15191 0.000051 [b7eeb424] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D9=
, ...}) =3D 0
15191 0.000057 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7edc000
15191 0.000032 [b7eeb424] read(4, "multi on\n", 4096) =3D 9
15191 0.000046 [b7eeb424] read(4, "", 4096) =3D 0
15191 0.000028 [b7eeb424] close(4) =3D 0
15191 0.000027 [b7eeb424] munmap(0xb7edc000, 4096) =3D 0
15191 0.000035 [b7eeb424] futex(0xb7d05ac0, FUTEX_WAKE, 2147483647) =3D 0=

15191 0.000037 [b7eeb424] open("/etc/hosts", O_RDONLY) =3D 4
15191 0.000043 [b7eeb424] fcntl64(4, F_GETFD) =3D 0
15191 0.000028 [b7eeb424] fcntl64(4, F_SETFD, FD_CLOEXEC) =3D 0
15191 0.000032 [b7eeb424] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D5=
79, ...}) =3D 0
15191 0.000055 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7edc000
15191 0.000032 [b7eeb424] read(4, "127.0.0.1\tlocalhost asus-laptop\n"...=
, 4096) =3D 579
15191 0.000065 [b7eeb424] read(4, "", 4096) =3D 0
15191 0.000032 [b7eeb424] close(4) =3D 0
15191 0.000027 [b7eeb424] munmap(0xb7edc000, 4096) =3D 0
15191 0.000038 [b7eeb424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
15191 0.000036 [b7eeb424] connect(4, {sa_family=3DAF_INET, sin_port=3Dhto=
ns(0), sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D 0
15191 0.000046 [b7eeb424] getsockname(4, {sa_family=3DAF_INET, sin_port=3D=
htons(51870), sin_addr=3Dinet_addr("127.0.0.1")}, [16]) =3D 0
15191 0.000062 [b7eeb424] close(4) =3D 0
15191 0.000050 [b7eeb424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
15191 0.000042 [b7eeb424] connect(4, {sa_family=3DAF_INET, sin_port=3Dhto=
ns(53), sin_addr=3Dinet_addr("1.1.1.1")}, 28) =3D 0
15191 0.000043 [b7eeb424] getsockname(4, {sa_family=3DAF_INET, sin_port=3D=
htons(34721), sin_addr=3Dinet_addr("<my_public_ip_address>")}, [16]) =3D =
0
15191 0.000077 [b7eeb424] close(4) =3D 0
15191 0.000038 [b7eeb424] futex(0xb7d05d08, FUTEX_WAKE, 2147483647) =3D 0=

15191 0.000043 [b7eeb424] getsockname(3, {sa_family=3DAF_INET, sin_port=3D=
htons(5060), sin_addr=3Dinet_addr("0.0.0.0")}, [16]) =3D 0
15191 0.000074 [b7eeb424] setsockopt(3, SOL_SOCKET, SO_RCVBUF, [25165824]=
, 4) =3D 0
15191 0.000036 [b7eeb424] setsockopt(3, SOL_SOCKET, SO_SNDBUF, [25165824]=
, 4) =3D 0
15191 0.000040 [b7eeb424] gettimeofday({1215118640, 429345}, NULL) =3D 0
15191 0.000039 [b7eeb424] getsockopt(3, SOL_SOCKET, SO_TYPE, [2], [4]) =3D=
 0
15191 0.000036 [b7eeb424] ioctl(3, FIONBIO, [1]) =3D 0
15191 0.000053 [b7eeb424] gettimeofday({1215118640, 429473}, NULL) =3D 0
15191 0.000039 [b7eeb424] write(1, " 22:57:20.429 udp0x8097428 SIP"..., 9=
5) =3D 95
15191 0.000051 [b7eeb424] gettimeofday({1215118640, 429563}, NULL) =3D 0
15191 0.000036 [b7eeb424] write(1, " 22:57:20.429 sip_endpoint.c Mod"...,=
 64) =3D 64
15191 0.000042 [b7eeb424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
15191 0.000042 [b7eeb424] open("/etc/hosts", O_RDONLY) =3D 4
15191 0.000040 [b7eeb424] fcntl64(4, F_GETFD) =3D 0
15191 0.000027 [b7eeb424] fcntl64(4, F_SETFD, FD_CLOEXEC) =3D 0
15191 0.000029 [b7eeb424] fstat64(4, {st_mode=3DS_IFREG|0644, st_size=3D5=
79, ...}) =3D 0
15191 0.000055 [b7eeb424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRI=
VATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7edc000
15191 0.000034 [b7eeb424] read(4, "127.0.0.1\tlocalhost asus-laptop\n"...=
, 4096) =3D 579
15191 0.000051 [b7eeb424] read(4, "", 4096) =3D 0
15191 0.000029 [b7eeb424] close(4) =3D 0
15191 0.000028 [b7eeb424] munmap(0xb7edc000, 4096) =3D 0
15191 0.000035 [b7eeb424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
15191 0.000035 [b7eeb424] connect(4, {sa_family=3DAF_INET, sin_port=3Dhto=
ns(0), sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D 0
15191 0.000039 [b7eeb424] getsockname(4, {sa_family=3DAF_INET, sin_port=3D=
htons(33334), sin_addr=3Dinet_addr("127.0.0.1")}, [16]) =3D 0
15191 0.000062 [b7eeb424] close(4) =3D 0
15191 0.000038 [b7eeb424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
15191 0.000036 [b7eeb424] connect(4, {sa_family=3DAF_INET, sin_port=3Dhto=
ns(53), sin_addr=3Dinet_addr("1.1.1.1")}, 28) =3D 0
15191 0.000042 [b7eeb424] getsockname(4, {sa_family=3DAF_INET, sin_port=3D=
htons(40791), sin_addr=3Dinet_addr("<my_public_ip_address>")}, [16]) =3D =
0
15191 0.000062 [b7eeb424] close(4) =3D 0
15191 0.000042 [b7eeb424] socket(PF_NETLINK, SOCK_RAW, 0) =3D 4
15191 0.000035 [b7eeb424] bind(4, {sa_family=3DAF_NETLINK, pid=3D0, group=
s=3D00000000}, 12) =3D 0
15191 0.000038 [b7eeb424] getsockname(4, {sa_family=3DAF_NETLINK, pid=3D1=
5191, groups=3D00000000}, [12]) =3D 0
15191 0.000060 [b7eeb424] time(NULL) =3D 1215118640
15191 0.000032 [b7eeb424] sendto(4, "\24\0\0\0\22\0\1\0030=3DmH\0\0\0\0\0=
!\312\267", 20, 0, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, =
12) =3D 20
15191 0.000072 [b7eeb424] recvmsg(4, {msg_name(12)=3D{sa_family=3DAF_NETL=
INK, pid=3D0, groups=3D00000000}, msg_iov(1)=3D[{"\354\0\0\0\20\0\2\0000=3D=
mHW;\0\0\0\0\4\3\1\0\0\0I\0\1\0"..., 4096}], msg_controllen=3D0, msg_flag=
s=3D0}, 0) =3D 1188
15191 0.000073 [b7eeb424] recvmsg(4, {msg_name(12)=3D{sa_family=3DAF_NETL=
INK, pid=3D0, groups=3D00000000}, msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0000=3D=
mHW;\0\0\0\0\0\0\1\0\0\0I\0\1\0\0"..., 4096}], msg_controllen=3D0, msg_fl=
ags=3D0}, 0) =3D 20
15191 0.000066 [b7eeb424] sendto(4, "\24\0\0\0\26\0\1\0031=3DmH\0\0\0\0\0=
!\312\267", 20, 0, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, =
12) =3D 20
15191 0.000055 [b7eeb424] recvmsg(4, {msg_name(12)=3D{sa_family=3DAF_NETL=
INK, pid=3D0, groups=3D00000000}, msg_iov(1)=3D[{"0\0\0\0\24\0\2\0001=3Dm=
HW;\0\0\2\10\200\376\1\0\0\0\10\0"..., 4096}], msg_controllen=3D0, msg_fl=
ags=3D0}, 0) =3D 160
15191 0.000067 [b7eeb424] recvmsg(4, {msg_name(12)=3D{sa_family=3DAF_NETL=
INK, pid=3D0, groups=3D00000000}, msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0001=3D=
mHW;\0\0\0\0\0\0\1\0\0\0\10\0\1\0"..., 4096}], msg_controllen=3D0, msg_fl=
ags=3D0}, 0) =3D 20
15191 0.000074 [b7eeb424] close(4) =3D 0
15191 0.000050 [0806e834] --- SIGSEGV (Segmentation fault) @ 0 (0) ---
15191 0.000150 [????????] +++ killed by SIGSEGV +++


When call to that function is disabled the program works fine.

=3D=3D=3D STRACE LOG ('strace -rif -o strace.log ./stateful_proxy-i686-pc=
-linux-gnu') =3D=3D=3D

12932      0.000000 [b7f9b424] execve("./stateful_proxy-i686-pc-linux-gnu=
", ["./stateful_proxy-i686-pc-linux-g"...], [/* 35 vars */]) =3D 0
12932      0.017510 [b7fcd9ed] uname({sys=3D"Linux", node=3D"asus-laptop"=
, ...}) =3D 0
12932      0.000211 [b7fccedb] brk(0)   =3D 0x8080000
12932      0.000046 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000060 [b7fcd933] mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fba000
12932      0.000041 [b7fcd781] access("/etc/ld.so.preload", R_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000054 [b7fcd644] open("/etc/ld.so.cache", O_RDONLY) =3D 3
12932      0.000040 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D71336, ...}) =3D 0
12932      0.000075 [b7fcd933] mmap2(NULL, 71336, PROT_READ, MAP_PRIVATE,=
 3, 0) =3D 0xb7fa8000
12932      0.000032 [b7fcd67d] close(3) =3D 0
12932      0.000031 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000050 [b7fcd644] open("/lib/tls/i686/cmov/libm.so.6", O_RDO=
NLY) =3D 3
12932      0.000057 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0`3\0\000"..., 512) =3D 512
12932      0.000054 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D145136, ...}) =3D 0
12932      0.000063 [b7fcd933] mmap2(NULL, 147584, PROT_READ|PROT_EXEC, M=
AP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7f83000
12932      0.000037 [b7fcd933] mmap2(0xb7fa6000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22) =3D 0xb7fa6000
12932      0.000051 [b7fcd67d] close(3) =3D 0
12932      0.000033 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000042 [b7fcd644] open("/lib/tls/i686/cmov/libnsl.so.1", O_R=
DONLY) =3D 3
12932      0.000048 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0p5\0\000"..., 512) =3D 512
12932      0.000051 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D76548, ...}) =3D 0
12932      0.000064 [b7fcd933] mmap2(NULL, 87808, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7f6d000
12932      0.000035 [b7fcd933] mmap2(0xb7f7f000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x11) =3D 0xb7f7f000
12932      0.000046 [b7fcd933] mmap2(0xb7f81000, 5888, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7f81000
12932      0.000042 [b7fcd67d] close(3) =3D 0
12932      0.000032 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000044 [b7fcd644] open("/lib/tls/i686/cmov/librt.so.1", O_RD=
ONLY) =3D 3
12932      0.000047 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0000\36\0"..., 512) =3D 512
12932      0.000052 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D30612, ...}) =3D 0
12932      0.000063 [b7fcd933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7f6c000
12932      0.000040 [b7fcd933] mmap2(NULL, 33384, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7f63000
12932      0.000035 [b7fcd933] mmap2(0xb7f6a000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6) =3D 0xb7f6a000
12932      0.000049 [b7fcd67d] close(3) =3D 0
12932      0.000033 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000041 [b7fcd644] open("/lib/tls/i686/cmov/libpthread.so.0",=
 O_RDONLY) =3D 3
12932      0.000049 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\240H\0"..., 512) =3D 512
12932      0.000051 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0755, st_siz=
e=3D89370, ...}) =3D 0
12932      0.000063 [b7fcd933] mmap2(NULL, 70104, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7f51000
12932      0.000036 [b7fcd933] mmap2(0xb7f5f000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe) =3D 0xb7f5f000
12932      0.000047 [b7fcd933] mmap2(0xb7f61000, 4568, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7f61000
12932      0.000042 [b7fcd67d] close(3) =3D 0
12932      0.000033 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000054 [b7fcd644] open("/usr/lib/i686/cmov/libssl.so.0.9.8",=
 O_RDONLY) =3D 3
12932      0.000047 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\220\255"..., 512) =3D 512
12932      0.009197 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D253120, ...}) =3D 0
12932      0.000106 [b7fcd933] mmap2(NULL, 256084, PROT_READ|PROT_EXEC, M=
AP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7f12000
12932      0.000059 [b7fcd933] mmap2(0xb7f4d000, 16384, PROT_READ|PROT_WR=
ITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3a) =3D 0xb7f4d000
12932      0.000067 [b7fcd67d] close(3) =3D 0
12932      0.000034 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000047 [b7fcd644] open("/usr/lib/i686/cmov/libcrypto.so.0.9.=
8", O_RDONLY) =3D 3
12932      0.000047 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\300Y\3"..., 512) =3D 512
12932      0.000052 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D1270520, ...}) =3D 0
12932      0.000063 [b7fcd933] mmap2(NULL, 1282904, PROT_READ|PROT_EXEC, =
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7dd8000
12932      0.000037 [b7fcd933] mmap2(0xb7efa000, 81920, PROT_READ|PROT_WR=
ITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x122) =3D 0xb7efa000
12932      0.000047 [b7fcd933] mmap2(0xb7f0e000, 13144, PROT_READ|PROT_WR=
ITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7f0e000
12932      0.000041 [b7fcd67d] close(3) =3D 0
12932      0.000033 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000044 [b7fcd644] open("/lib/tls/i686/cmov/libc.so.6", O_RDO=
NLY) =3D 3
12932      0.000045 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\240O\1"..., 512) =3D 512
12932      0.000049 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D1241392, ...}) =3D 0
12932      0.000066 [b7fcd933] mmap2(NULL, 1247388, PROT_READ|PROT_EXEC, =
MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7ca7000
12932      0.000036 [b7fcd933] mmap2(0xb7dce000, 28672, PROT_READ|PROT_WR=
ITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x127) =3D 0xb7dce000
12932      0.000044 [b7fcd933] mmap2(0xb7dd5000, 10396, PROT_READ|PROT_WR=
ITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0xb7dd5000
12932      0.000041 [b7fcd67d] close(3) =3D 0
12932      0.000041 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000042 [b7fcd644] open("/lib/tls/i686/cmov/libdl.so.2", O_RD=
ONLY) =3D 3
12932      0.000116 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\20\f\0"..., 512) =3D 512
12932      0.000052 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D9592, ...}) =3D 0
12932      0.000063 [b7fcd933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7ca6000
12932      0.000040 [b7fcd933] mmap2(NULL, 12404, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7ca2000
12932      0.000036 [b7fcd933] mmap2(0xb7ca4000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1) =3D 0xb7ca4000
12932      0.000048 [b7fcd67d] close(3) =3D 0
12932      0.000048 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000052 [b7fcd644] open("/usr/lib/libz.so.1", O_RDONLY) =3D 3=

12932      0.036021 [b7fcd6c4] read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\340\26"..., 512) =3D 512
12932      0.000087 [b7fcd60e] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D78500, ...}) =3D 0
12932      0.000106 [b7fcd933] mmap2(NULL, 81456, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 3, 0) =3D 0xb7c8e000
12932      0.000065 [b7fcd933] mmap2(0xb7ca1000, 4096, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12) =3D 0xb7ca1000
12932      0.000043 [b7fcd67d] close(3) =3D 0
12932      0.000074 [b7fcd933] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7c8d000
12932      0.000290 [b7fcd9b4] mprotect(0xb7dce000, 20480, PROT_READ) =3D=
 0
12932      0.000303 [b7fbfc11] set_thread_area({entry_number:-1 -> 6, bas=
e_addr:0xb7c8d6c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only=
:0, limit_in_pages:1, seg_not_present:0, useable:1}) =3D 0
12932      0.000063 [b7fcd971] munmap(0xb7fa8000, 71336) =3D 0
12932      0.000039 [b7fbc424] set_tid_address(0xb7c8d708) =3D 12932
12932      0.000041 [b7fbc424] rt_sigaction(SIGRTMIN, {0xb7f554c0, [], SA=
_SIGINFO}, NULL, 8) =3D 0
12932      0.000049 [b7fbc424] rt_sigaction(SIGRT_1, {0xb7f55420, [], SA_=
RESTART|SA_SIGINFO}, NULL, 8) =3D 0
12932      0.000041 [b7fbc424] rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], =
NULL, 8) =3D 0
12932      0.000041 [b7fbc424] getrlimit(RLIMIT_STACK, {rlim_cur=3D8192*1=
024, rlim_max=3DRLIM_INFINITY}) =3D 0
12932      0.000061 [b7fbc424] uname({sys=3D"Linux", node=3D"asus-laptop"=
, ...}) =3D 0
12932      0.002334 [b7fbc424] gettimeofday({1215165772, 445126}, NULL) =3D=
 0
12932      0.000064 [b7fbc424] gettimeofday({1215165772, 445183}, NULL) =3D=
 0
12932      0.000118 [b7fbc424] brk(0)   =3D 0x8080000
12932      0.000048 [b7fbc424] brk(0x80a1000) =3D 0x80a1000
12932      0.000077 [b7fbc424] open("/etc/localtime", O_RDONLY) =3D 3
12932      0.000046 [b7fbc424] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D2652, ...}) =3D 0
12932      0.000068 [b7fbc424] fstat64(3, {st_mode=3DS_IFREG|0644, st_siz=
e=3D2652, ...}) =3D 0
12932      0.000064 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fb9000
12932      0.000035 [b7fbc424] read(3, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0=
\0\0\0\0\6\0\0\0\6\0\0"..., 4096) =3D 2652
12932      0.000062 [b7fbc424] close(3) =3D 0
12932      0.000030 [b7fbc424] munmap(0xb7fb9000, 4096) =3D 0
12932      0.000052 [b7fbc424] fstat64(1, {st_mode=3DS_IFCHR|0620, st_rde=
v=3Dmakedev(136, 0), ...}) =3D 0
12932      0.000065 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fb9000
12932      0.000038 [b7fbc424] write(1, " 12:02:52.445 os_core_unix.c pjl=
"..., 71) =3D 71
12932      0.000754 [b7fbc424] uname({sys=3D"Linux", node=3D"asus-laptop"=
, ...}) =3D 0
12932      0.000240 [b7fbc424] mmap2(NULL, 266240, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7c4c000
12932      0.000040 [b7fbc424] mmap2(NULL, 266240, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7c0b000
12932      0.000350 [b7fbc424] gettimeofday({1215165772, 447265}, NULL) =3D=
 0
12932      0.000040 [b7fbc424] write(1, " 12:02:52.447          pjlib sel=
"..., 69) =3D 69
12932      0.000063 [b7fbc424] gettimeofday({1215165772, 447367}, NULL) =3D=
 0
12932      0.000038 [b7fbc424] write(1, " 12:02:52.447 sip_endpoint.c Mod=
"..., 63) =3D 63
12932      0.000047 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000116 [b7fbc424] gettimeofday({1215165772, 447584}, NULL) =3D=
 0
12932      0.000053 [b7fbc424] write(1, " 12:02:52.447 sip_endpoint.c Mod=
"..., 63) =3D 63
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000032 [b7fbc424] gettimeofday({1215165772, 447698}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.447 sip_endpoint.c Mod=
"..., 67) =3D 67
12932      0.000044 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000040 [b7fbc424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D=
 3
12932      0.000051 [b7fbc424] bind(3, {sa_family=3DAF_INET, sin_port=3Dh=
tons(5060), sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
12932      0.000057 [b7fbc424] getsockname(3, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(5060), sin_addr=3Dinet_addr("0.0.0.0")}, [16]) =3D 0
12932      0.000102 [b7fbc424] gettimeofday({1215165772, 448030}, NULL) =3D=
 0
12932      0.000039 [b7fbc424] open("/etc/resolv.conf", O_RDONLY) =3D 4
12932      0.000047 [b7fbc424] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D46, ...}) =3D 0
12932      0.000064 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fb8000
12932      0.000035 [b7fbc424] read(4, "nameserver 85.37.17.47\nnameserve=
"..., 4096) =3D 46
12932      0.000060 [b7fbc424] read(4, "", 4096) =3D 0
12932      0.000031 [b7fbc424] close(4) =3D 0
12932      0.000029 [b7fbc424] munmap(0xb7fb8000, 4096) =3D 0
12932      0.000046 [b7fbc424] uname({sys=3D"Linux", node=3D"asus-laptop"=
, ...}) =3D 0
12932      0.000155 [b7fbc424] socket(PF_FILE, SOCK_STREAM, 0) =3D 4
12932      0.000039 [b7fbc424] fcntl64(4, F_GETFL) =3D 0x2 (flags O_RDWR)=

12932      0.000051 [b7fbc424] fcntl64(4, F_SETFL, O_RDWR|O_NONBLOCK) =3D=
 0
12932      0.000037 [b7fbc424] connect(4, {sa_family=3DAF_FILE, path=3D"/=
var/run/nscd/socket"}, 110) =3D -1 ENOENT (No such file or directory)
12932      0.000085 [b7fbc424] close(4) =3D 0
12932      0.000038 [b7fbc424] socket(PF_FILE, SOCK_STREAM, 0) =3D 4
12932      0.000032 [b7fbc424] fcntl64(4, F_GETFL) =3D 0x2 (flags O_RDWR)=

12932      0.000030 [b7fbc424] fcntl64(4, F_SETFL, O_RDWR|O_NONBLOCK) =3D=
 0
12932      0.000034 [b7fbc424] connect(4, {sa_family=3DAF_FILE, path=3D"/=
var/run/nscd/socket"}, 110) =3D -1 ENOENT (No such file or directory)
12932      0.000069 [b7fbc424] close(4) =3D 0
12932      0.000035 [b7fbc424] open("/etc/nsswitch.conf", O_RDONLY) =3D 4=

12932      0.000047 [b7fbc424] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D475, ...}) =3D 0
12932      0.000064 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fb8000
12932      0.000033 [b7fbc424] read(4, "# /etc/nsswitch.conf\n#\n# Exampl=
e"..., 4096) =3D 475
12932      0.000067 [b7fbc424] read(4, "", 4096) =3D 0
12932      0.000030 [b7fbc424] close(4) =3D 0
12932      0.000028 [b7fbc424] munmap(0xb7fb8000, 4096) =3D 0
12932      0.000049 [b7fcd644] open("/etc/ld.so.cache", O_RDONLY) =3D 4
12932      0.000041 [b7fcd60e] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D71336, ...}) =3D 0
12932      0.000062 [b7fcd933] mmap2(NULL, 71336, PROT_READ, MAP_PRIVATE,=
 4, 0) =3D 0xb7bf9000
12932      0.000034 [b7fcd67d] close(4) =3D 0
12932      0.000033 [b7fcd781] access("/etc/ld.so.nohwcap", F_OK) =3D -1 =
ENOENT (No such file or directory)
12932      0.000052 [b7fcd644] open("/lib/tls/i686/cmov/libnss_files.so.2=
", O_RDONLY) =3D 4
12932      0.000054 [b7fcd6c4] read(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3=
\0\3\0\1\0\0\0\200\33"..., 512) =3D 512
12932      0.000053 [b7fcd60e] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D38372, ...}) =3D 0
12932      0.000065 [b7fcd933] mmap2(NULL, 41620, PROT_READ|PROT_EXEC, MA=
P_PRIVATE|MAP_DENYWRITE, 4, 0) =3D 0xb7fae000
12932      0.000037 [b7fcd933] mmap2(0xb7fb7000, 8192, PROT_READ|PROT_WRI=
TE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x8) =3D 0xb7fb7000
12932      0.000050 [b7fcd67d] close(4) =3D 0
12932      0.000064 [b7fcd971] munmap(0xb7bf9000, 71336) =3D 0
12932      0.000047 [b7fbc424] open("/etc/host.conf", O_RDONLY) =3D 4
12932      0.014710 [b7fbc424] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D9, ...}) =3D 0
12932      0.000106 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fad000
12932      0.000056 [b7fbc424] read(4, "multi on\n", 4096) =3D 9
12932      0.004583 [b7fbc424] read(4, "", 4096) =3D 0
12932      0.000049 [b7fbc424] close(4) =3D 0
12932      0.000047 [b7fbc424] munmap(0xb7fad000, 4096) =3D 0
12932      0.000057 [b7fbc424] futex(0xb7dd6ac0, FUTEX_WAKE, 2147483647) =
=3D 0
12932      0.000068 [b7fbc424] open("/etc/hosts", O_RDONLY) =3D 4
12932      0.000044 [b7fbc424] fcntl64(4, F_GETFD) =3D 0
12932      0.000029 [b7fbc424] fcntl64(4, F_SETFD, FD_CLOEXEC) =3D 0
12932      0.000033 [b7fbc424] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D579, ...}) =3D 0
12932      0.000063 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fad000
12932      0.000034 [b7fbc424] read(4, "127.0.0.1\tlocalhost asus-laptop\=
n"..., 4096) =3D 579
12932      0.000068 [b7fbc424] read(4, "", 4096) =3D 0
12932      0.000033 [b7fbc424] close(4) =3D 0
12932      0.000029 [b7fbc424] munmap(0xb7fad000, 4096) =3D 0
12932      0.000039 [b7fbc424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D=
 4
12932      0.000037 [b7fbc424] connect(4, {sa_family=3DAF_INET, sin_port=3D=
htons(0), sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D 0
12932      0.000059 [b7fbc424] getsockname(4, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(54238), sin_addr=3Dinet_addr("127.0.0.1")}, [16]) =3D 0
12932      0.000072 [b7fbc424] close(4) =3D 0
12932      0.000051 [b7fbc424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D=
 4
12932      0.000043 [b7fbc424] connect(4, {sa_family=3DAF_INET, sin_port=3D=
htons(53), sin_addr=3Dinet_addr("1.1.1.1")}, 28) =3D 0
12932      0.000054 [b7fbc424] getsockname(4, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(50396), sin_addr=3Dinet_addr("<my_public_ip_address>")}, [16]=
) =3D 0
12932      0.000087 [b7fbc424] close(4) =3D 0
12932      0.000038 [b7fbc424] futex(0xb7dd6d08, FUTEX_WAKE, 2147483647) =
=3D 0
12932      0.000043 [b7fbc424] getsockname(3, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(5060), sin_addr=3Dinet_addr("0.0.0.0")}, [16]) =3D 0
12932      0.000084 [b7fbc424] setsockopt(3, SOL_SOCKET, SO_RCVBUF, [2516=
5824], 4) =3D 0
12932      0.000039 [b7fbc424] setsockopt(3, SOL_SOCKET, SO_SNDBUF, [2516=
5824], 4) =3D 0
12932      0.000042 [b7fbc424] gettimeofday({1215165772, 470592}, NULL) =3D=
 0
12932      0.000043 [b7fbc424] getsockopt(3, SOL_SOCKET, SO_TYPE, [2], [4=
]) =3D 0
12932      0.000037 [b7fbc424] ioctl(3, FIONBIO, [1]) =3D 0
12932      0.000053 [b7fbc424] gettimeofday({1215165772, 470726}, NULL) =3D=
 0
12932      0.000040 [b7fbc424] write(1, " 12:02:52.470   udp0x8097428 SIP=
"..., 96) =3D 96
12932      0.000054 [b7fbc424] gettimeofday({1215165772, 470820}, NULL) =3D=
 0
12932      0.000038 [b7fbc424] write(1, " 12:02:52.470 sip_endpoint.c Mod=
"..., 64) =3D 64
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000044 [b7fbc424] open("/etc/hosts", O_RDONLY) =3D 4
12932      0.000040 [b7fbc424] fcntl64(4, F_GETFD) =3D 0
12932      0.000030 [b7fbc424] fcntl64(4, F_SETFD, FD_CLOEXEC) =3D 0
12932      0.000029 [b7fbc424] fstat64(4, {st_mode=3DS_IFREG|0644, st_siz=
e=3D579, ...}) =3D 0
12932      0.000063 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fad000
12932      0.000034 [b7fbc424] read(4, "127.0.0.1\tlocalhost asus-laptop\=
n"..., 4096) =3D 579
12932      0.000056 [b7fbc424] read(4, "", 4096) =3D 0
12932      0.000030 [b7fbc424] close(4) =3D 0
12932      0.000029 [b7fbc424] munmap(0xb7fad000, 4096) =3D 0
12932      0.000038 [b7fbc424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D=
 4
12932      0.000036 [b7fbc424] connect(4, {sa_family=3DAF_INET, sin_port=3D=
htons(0), sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D 0
12932      0.000043 [b7fbc424] getsockname(4, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(46980), sin_addr=3Dinet_addr("127.0.0.1")}, [16]) =3D 0
12932      0.000072 [b7fbc424] close(4) =3D 0
12932      0.000040 [b7fbc424] socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D=
 4
12932      0.000038 [b7fbc424] connect(4, {sa_family=3DAF_INET, sin_port=3D=
htons(53), sin_addr=3Dinet_addr("1.1.1.1")}, 28) =3D 0
12932      0.000046 [b7fbc424] getsockname(4, {sa_family=3DAF_INET, sin_p=
ort=3Dhtons(37894), sin_addr=3Dinet_addr("<my_public_ip_address>")}, [16]=
) =3D 0
12932      0.000071 [b7fbc424] close(4) =3D 0
12932      0.000033 [b7fbc424] gettimeofday({1215165772, 471674}, NULL) =3D=
 0
12932      0.000046 [b7fbc424] write(1, " 12:02:52.471 stateful_proxy Pro=
"..., 67) =3D 67
12932      0.000055 [b7fbc424] gettimeofday({1215165772, 471776}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.471 stateful_proxy Loc=
"..., 49) =3D 49
12932      0.000048 [b7fbc424] gettimeofday({1215165772, 471860}, NULL) =3D=
 0
12932      0.000044 [b7fbc424] write(1, " 12:02:52.471 stateful_proxy  82=
"..., 49) =3D 49
12932      0.000043 [b7fbc424] gettimeofday({1215165772, 471947}, NULL) =3D=
 0
12932      0.000036 [b7fbc424] write(1, " 12:02:52.471 stateful_proxy  12=
"..., 45) =3D 45
12932      0.000043 [b7fbc424] gettimeofday({1215165772, 472027}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.472 stateful_proxy  as=
"..., 47) =3D 47
12932      0.000043 [b7fbc424] gettimeofday({1215165772, 472106}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.472 stateful_proxy  lo=
"..., 45) =3D 45
12932      0.000044 [b7fbc424] gettimeofday({1215165772, 472188}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.472 sip_endpoint.c Mod=
"..., 68) =3D 68
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000030 [b7fbc424] gettimeofday({1215165772, 472300}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.472 sip_endpoint.c Mod=
"..., 70) =3D 70
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000044 [b7fbc424] mmap2(NULL, 8392704, PROT_READ|PROT_WRITE,=
 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb740a000
12932      0.000060 [b7fbc424] mprotect(0xb740a000, 4096, PROT_NONE) =3D =
0
12932      0.000039 [b7d72488] clone(child_stack=3D0xb7c0a4c4, flags=3DCL=
ONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLON=
E_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID|CLONE_DETACHED, parent_=
tidptr=3D0xb7c0abf8, {entry_number:6, base_addr:0xb7c0abb0, limit:1048575=
, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_pr=
esent:0, useable:1}, child_tidptr=3D0xb7c0abf8) =3D 12933
12933      0.000085 [b7fbc424] select(1024, [3], [], [], {0, 10000} <unfi=
nished ...>
12932      0.000165 [b7fbc424] write(1, "\nMenu:\n  q    quit\n  d    dum=
p s"..., 66) =3D 66
12932      0.000047 [b7fbc424] write(1, "\n", 1) =3D 1
12932      0.000037 [b7fbc424] fstat64(0, {st_mode=3DS_IFCHR|0620, st_rde=
v=3Dmakedev(136, 0), ...}) =3D 0
12932      0.000065 [b7fbc424] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MA=
P_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0xb7fad000
12932      0.000035 [b7fbc424] read(0,  <unfinished ...>
12933      0.012107 [b7fbc424] <... select resumed> ) =3D 0 (Timeout)
12933      0.000038 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013361 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013294 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013333 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013334 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013354 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013323 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013323 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013334 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013351 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013315 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013340 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013326 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013354 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013313 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013333 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013344 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013341 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013319 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013330 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013338 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013354 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013308 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013333 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013333 [b7fbc424] select(1024, [3], [], [], {0, 10000}) =3D =
0 (Timeout)
12933      0.013383 [b7fbc424] select(1024, [3], [], [], {0, 10000} <unfi=
nished ...>
12932      0.006658 [b7fbc424] <... read resumed> "q\n", 1024) =3D 2
12932      0.000054 [b7fbc424] futex(0xb7c0abf8, FUTEX_WAIT, 12933, NULL =
<unfinished ...>
12933      0.006591 [b7fbc424] <... select resumed> ) =3D 0 (Timeout)
12933      0.000044 [b7f56299] _exit(0) =3D ?
12932      0.000046 [b7fbc424] <... futex resumed> ) =3D 0
12932      0.000031 [b7fbc424] gettimeofday({1215165772, 831905}, NULL) =3D=
 0
12932      0.000068 [b7fbc424] write(1, " 12:02:52.831 sip_endpoint.c Mod=
"..., 72) =3D 72
12932      0.000078 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000030 [b7fbc424] gettimeofday({1215165772, 832074}, NULL) =3D=
 0
12932      0.000039 [b7fbc424] write(1, " 12:02:52.832 sip_endpoint.c Mod=
"..., 69) =3D 69
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000029 [b7fbc424] gettimeofday({1215165772, 832187}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.832 sip_endpoint.c Mod=
"..., 70) =3D 70
12932      0.000070 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000033 [b7fbc424] gettimeofday({1215165772, 832327}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.832 sip_transactio Sto=
"..., 63) =3D 63
12932      0.000119 [b7fbc424] gettimeofday({1215165772, 832484}, NULL) =3D=
 0
12932      0.000038 [b7fbc424] write(1, " 12:02:52.832 sip_transactio Tra=
"..., 64) =3D 64
12932      0.000055 [b7fbc424] gettimeofday({1215165772, 832576}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.832 sip_endpoint.c Mod=
"..., 65) =3D 65
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000029 [b7fbc424] gettimeofday({1215165772, 832687}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.832 sip_endpoint.c Mod=
"..., 65) =3D 65
12932      0.000056 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000029 [b7fbc424] gettimeofday({1215165772, 832810}, NULL) =3D=
 0
12932      0.000037 [b7fbc424] write(1, " 12:02:52.832 sip_endpoint.c Mod=
"..., 66) =3D 66
12932      0.000045 [b7fbc424] futex(0x80806d8, FUTEX_WAKE, 1) =3D 0
12932      0.000033 [b7fbc424] close(3) =3D 0
12932      0.000037 [b7fbc424] gettimeofday({1215165772, 832962}, NULL) =3D=
 0
12932      0.000036 [b7fbc424] gettimeofday({1215165772, 832997}, NULL) =3D=
 0
12932      0.000038 [b7fbc424] nanosleep({0, 1000000}, NULL) =3D 0
12932      0.002057 [b7fbc424] munmap(0xb7c4c000, 266240) =3D 0
12932      0.000038 [b7fbc424] munmap(0xb7c0b000, 266240) =3D 0
12932      0.000058 [b7fbc424] gettimeofday({1215165772, 835189}, NULL) =3D=
 0
12932      0.000039 [b7fbc424] write(1, " 12:02:52.835 sip_endpoint.c End=
"..., 58) =3D 58
12932      0.000085 [b7fbc424] munmap(0xb7fb9000, 4096) =3D 0
12932      0.000033 [b7fbc424] exit_group(0) =3D ?


What do you suggest me to do? I'm out of ideas, as I'm not a Kernel hacke=
r.

Thank you in advance.
Best regards.

--=20
Filippo Zangheri

GPG key ID: 0x6C1F2F2F


--------------enigDBA5D0F2D439BC3EC8B1FE8E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIbfgfjzxMG2wfLy8RAqO/AJ0WHI2NrRCJDaNuTUW0AjcSV9L5gACgmjIc
tIqKANeTOG3P9p5fvKqU3Gk=
=rPbY
-----END PGP SIGNATURE-----

--------------enigDBA5D0F2D439BC3EC8B1FE8E--

