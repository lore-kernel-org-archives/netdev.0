From: "Dr. Peter Bieringer " <pb@bieringer.de>
Subject: Ooops: 2.5.70 kernel BUG at net/xfrm/xfrm_policy.c - ping crashes
Date: Wed, 04 Jun 2003 17:40:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604154003.5AA111387A@smtp2.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Maillist USAGI-users" <usagi-users@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Maillist netdev" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

is this helpful? Happen on playing around with IPsec on 2.5.70, caused by a 
ping to a destination (1.2.3.4) in IPsec topology. 

Jun  4 17:41:31 racoonhost kernel: ------------[ cut here ]------------
Jun  4 17:41:31 racoonhost kernel: kernel BUG at net/xfrm/xfrm_policy.c:185!
Jun  4 17:41:31 racoonhost kernel: invalid operand: 0000 [#1]
Jun  4 17:41:31 racoonhost kernel: CPU:    0
Jun  4 17:41:31 racoonhost kernel: EIP:    0060:[<c022bc0e>]    Tainted: P
Jun  4 17:41:31 racoonhost kernel: EFLAGS: 00010246
Jun  4 17:41:31 racoonhost kernel: eax: c6f80a01   ebx: c1b45000   ecx: 
c6f80a80   edx: c1b45000
Jun  4 17:41:31 racoonhost kernel: esi: c1b45000   edi: 00000000   ebp: 
c6f80a80   esp: c0985d04
Jun  4 17:41:31 racoonhost kernel: ds: 007b   es: 007b   ss: 0068
Jun  4 17:41:31 racoonhost kernel: Process ping (pid: 23407, 
threadinfo=c0984000 task=c4e6c6a0)
Jun  4 17:41:31 racoonhost kernel: Stack: c0985ddc c022d09d c1b45000 
c0985ddc 00000002 0000002e 00000001 c6f80a80
Jun  4 17:41:31 racoonhost kernel:        c1b45000 c0a79d80 c016eff7 
fd010018 c6d9b900 c027c7e0 1f3e030a 00000000
Jun  4 17:41:31 racoonhost kernel:        00000000 00000000 00000000 
00000000 00000000 00000000 00000000 00000000
Jun  4 17:41:31 racoonhost kernel: Call Trace: [<c022d09d>]  [<c016eff7>]  
[<c01f8d33>]  [<c01f8e2b>]  [<c0219110>]  [<c01358a0>]  [<c021f142>]  
[<c01e665d>]  [<c01e557e>]  [<c01e55cc>]  [<c021edc8>]  [<c01e61da>]  
[<c01e62ad>]  [<c01e6f94>]  [<c0122868>]  [<c01379b4>]  [<c010a6b3>]
Jun  4 17:41:31 racoonhost kernel: Code: 0f 0b b9 00 89 49 25 c0 8b 8b c8 00 
00 00 85 c9 74 08 0f 0b
Jun  4 17:41:33 racoonhost kernel:  ------------[ cut here ]------------
Jun  4 17:41:33 racoonhost kernel: kernel BUG at net/xfrm/xfrm_policy.c:185!
Jun  4 17:41:33 racoonhost kernel: invalid operand: 0000 [#2]
Jun  4 17:41:33 racoonhost kernel: CPU:    0
Jun  4 17:41:33 racoonhost kernel: EIP:    0060:[<c022bc0e>]    Tainted: P
Jun  4 17:41:33 racoonhost kernel: EFLAGS: 00010246
Jun  4 17:41:33 racoonhost kernel: eax: c6f80a01   ebx: c1b45000   ecx: 
c6f80a80   edx: c1b45000
Jun  4 17:41:33 racoonhost kernel: esi: 00000002   edi: c1b45000   ebp: 
c6f80a80   esp: c094bd04
Jun  4 17:41:33 racoonhost kernel: ds: 007b   es: 007b   ss: 0068
Jun  4 17:41:33 racoonhost kernel: Process ping (pid: 23408, 
threadinfo=c094a000 task=c4e6c6a0)
Jun  4 17:41:33 racoonhost kernel: Stack: c1b45000 c022d09d c1b45000 
c2d38ab0 00000002 0000002e c7ee1f00 c6f80a80
Jun  4 17:41:33 racoonhost kernel:        c1b45000 c0a79d80 c016eff7 
c016f045 c7ee1f00 c7ee3800 00000000 c7ee1f00
Jun  4 17:41:33 racoonhost kernel:        c7eb2100 c7ece494 c01767ee 
c2d38ab0 c0d11424 c2d38ab0 00000000 00000000
Jun  4 17:41:33 racoonhost kernel: Call Trace: [<c022d09d>]  [<c016eff7>]  
[<c016f045>]  [<c01767ee>]  [<c016f2b2>]  [<c0115a61>]  [<c012dcfb>]  
[<c01f8d33>]  [<c01f8e
2b>]  [<c0219110>]  [<c01358a0>]  [<c021f142>]  [<c01e665d>]  [<c01e557e>]  
[<c01e55cc>]  [<c021edc8>]  [<c01e61da>]  [<c01e62ad>]  [<c01e6f94>]  
[<c0122868>]  [<c0137
9b4>]  [<c010a6b3>]
Jun  4 17:41:33 racoonhost kernel: Code: 0f 0b b9 00 89 49 25 c0 8b 8b c8 00 
00 00 85 c9 74 08 0f 0b 

Btw: ping segfaults...that is not good because ping is usually with suid bit 
set installed: 

# stat `which ping`
 File: "/bin/ping"
 Size: 35192           Blocks: 72         IO Block: -4611693715008778240 
Regular File
Device: 303h/771d       Inode: 128458      Links: 1
Access: (4755/-rwsr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: Wed Jun  4 17:43:44 2003
Modify: Thu Apr 18 23:40:02 2002
Change: Tue Nov  5 18:25:31 2002 


# strace ping 1.2.3.4
execve("/bin/ping", ["ping", "1.2.3.4"], [/* 29 vars */]) = 0
uname({sys="Linux", node="racoonhost.lab.aerasec.de", ...}) = 0
brk(0)                                  = 0x8063000
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=14186, ...}) = 0
old_mmap(NULL, 14186, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40014000
close(3)                                = 0
open("/lib/libresolv.so.2", O_RDONLY)   = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\20\'\0"..., 1024) = 
1024
fstat64(3, {st_mode=S_IFREG|0755, st_size=68925, ...}) = 0
old_mmap(NULL, 69408, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40018000
mprotect(0x40026000, 12064, PROT_NONE)  = 0
old_mmap(0x40026000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 
0xe000) = 0x40026000
old_mmap(0x40027000, 7968, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40027000
close(3)                                = 0
open("/lib/i686/libc.so.6", O_RDONLY)   = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0Pv\1B4\0"..., 1024) 
= 1024
fstat64(3, {st_mode=S_IFREG|0755, st_size=1402035, ...}) = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) 
= 0x40029000
old_mmap(0x42000000, 1264960, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 
0x42000000
mprotect(0x4212c000, 36160, PROT_NONE)  = 0
old_mmap(0x4212c000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 
0x12c000) = 0x4212c000
old_mmap(0x42131000, 15680, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x42131000
close(3)                                = 0
munmap(0x40014000, 14186)               = 0
brk(0)                                  = 0x8063000
brk(0x8063030)                          = 0x8063030
brk(0x8064000)                          = 0x8064000
socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) = 3
getuid32()                              = 0
setuid32(0)                             = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sin_family=AF_INET, sin_port=htons(1025), 
sin_addr=inet_addr("1.2.3.4")}}, 16 <unfinished ...>
+++ killed by SIGSEGV +++ 


# rpm -qf `which ping`
iputils-20020124-3 

# rpm -qi iputils-20020124-3
Name        : iputils                      Relocations: /usr
Version     : 20020124                          Vendor: Red Hat, Inc.
Release     : 3                             Build Date: Thu 18 Apr 2002 
11:40:05 PM CEST
Install date: Tue 05 Nov 2002 06:25:31 PM CET      Build Host: 
stripples.devel.redhat.com
Group       : System Environment/Daemons    Source RPM: 
iputils-20020124-3.src.rpm
Size        : 188776                           License: BSD
Packager    : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>
Summary     : Network monitoring tools including ping.
Description :
The iputils package contains basic utilities for monitoring a network,
including ping. The ping command sends a series of ICMP protocol
ECHO_REQUEST packets to a specified network host to discover whether
the target machine is alive and receiving network traffic. 

 

Hope this helps,
Peter 

-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/ 
