From: "Andreas Westin" <andwes-8@student.luth.se>
Subject: bug ?
Date: Mon, 17 Mar 2003 15:06:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001101c2ec8e$5da12bf0$abddf082@legion>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I've gotten this "crash" now several times with >=2.4.20. It usually happens
within 1-2 days after bootup while downloading a larger amount of data at
around 500k/s.

Using gentoo linux on a dual 400mhz (celeron) abit bp6, i know this could be
due to hardware problems but i thought that I might aswell report it if its
a real bug. I hope that the info below is all that you need.

/Andreas

Network driver:
8139too Fast Ethernet driver 0.9.26
eth0: RealTek RTL8139 Fast Ethernet at 0xd8800000, 00:d0:70:01:0f:2f, IRQ 18
eth0:  Identified 8139 chip type 'RTL-8139C'


Unable to handle kernel paging request at virtual address e9272d39
c026c49f
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c026c49f>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00210246
eax: 00008000   ebx: e9272d0d   ecx: d561e3a0   edx: 00000000
esi: cad75f6c   edi: cc47bec0   ebp: cad75f6c   esp: cad75ee4
ds: 0018   es: 0018   ss: 0018
Process ncftp (pid: 31976, stackpage=cad75000)
Stack: d561e3a0 cad75f6c 00008000 00000000 00000000 cad75efc 00000000
00008000
       cad75f20 c022c008 cc47bec0 cad75f6c 00008000 00000000 cad75f20
00000000
       00000000 00000000 00000000 00000000 00000049 cad74000 00000064
d65bb520
Call Trace:    [<c022c008>] [<c022c147>] [<c013ce97>] [<c010773f>]
Code: ff 53 2c 85 c0 89 c2 78 07 8b 44 24 18 89 46 04 8b 5c 24 1c


>>EIP; c026c49f <inet_recvmsg+4f/70>   <=====

Trace; c022c008 <sock_recvmsg+58/f0>
Trace; c022c147 <sock_read+a7/b0>
Trace; c013ce97 <sys_read+97/140>
Trace; c010773f <system_call+33/38>

Code;  c026c49f <inet_recvmsg+4f/70>
00000000 <_EIP>:
Code;  c026c49f <inet_recvmsg+4f/70>   <=====
   0:   ff 53 2c                  call   *0x2c(%ebx)   <=====
Code;  c026c4a2 <inet_recvmsg+52/70>
   3:   85 c0                     test   %eax,%eax
Code;  c026c4a4 <inet_recvmsg+54/70>
   5:   89 c2                     mov    %eax,%edx
Code;  c026c4a6 <inet_recvmsg+56/70>
   7:   78 07                     js     10 <_EIP+0x10>
Code;  c026c4a8 <inet_recvmsg+58/70>
   9:   8b 44 24 18               mov    0x18(%esp,1),%eax
Code;  c026c4ac <inet_recvmsg+5c/70>
   d:   89 46 04                  mov    %eax,0x4(%esi)
Code;  c026c4af <inet_recvmsg+5f/70>
  10:   8b 5c 24 1c               mov    0x1c(%esp,1),%ebx


Linux hostname 2.4.21-pre5 #2 SMP Fri Feb 28 00:03:43 CET 2003 i686 Celeron
(Mendocino) GenuineIntel GNU/Linux

Gnu C                  3.2.2
Gnu make               3.80
util-linux             2.11z
mount                  2.11z
modutils               2.4.23
e2fsprogs              1.32
reiserfsprogs          3.6.3
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 3.1.6
Net-tools              1.60
Kbd                    1.06
Sh-utils               2.0.15
