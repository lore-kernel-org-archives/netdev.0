From: =?iso-8859-1?Q?Gu=F0mundur_D=2E?= Haraldsson <gdh@binhex.EU.org>
Subject: IPv6 kernel ooops
Date: Sat, 24 Apr 2004 22:23:41 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040424222340.GA10595@binhex.EU.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: gdh@binhex.EU.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi

I got this oops on my machine tonight.

I don't know what query to BIND caused it, but I've got an oops like this b=
efore!

[root@binhex gdh]# ksymoops  -k /proc/ksyms -l /proc/modules -o /lib/module=
s/2.4.22-1.2174.nptl/ -m /boot/System.map-2.4.22-1.2174.nptl  < blah
ksymoops 2.4.5 on i586 2.4.22-1.2174.nptl.  Options used
     -V (default)
     -k /proc/ksyms (specified)
     -l /proc/modules (specified)
     -o /lib/modules/2.4.22-1.2174.nptl/ (specified)
     -m /boot/System.map-2.4.22-1.2174.nptl (specified)

Unable to handle kernel NULL pointer dereference at virtual address 0000000c
c68d4fd5
*pde =3D 034ff067
Oops: 0000
CPU:    0
EIP:    0060:[<c68d4fd5>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010202
eax: 00000000   ebx: c26271a0   ecx: c5e97bbc   edx: 0000a7eb
esi: 00000000   edi: c39d9d94   ebp: 091dc910   esp: c39d9d04
ds: 0068   es: 0068   ss: 0068
Process named (pid: 19424, stackpage=3Dc39d9000)
Stack: c26271a0 0000a7eb c02112f0 00000000 c5e97bbc 00000000 c3b2f220 00000=
000=20
       c03e2458 c39d9dc4 00000064 00000000 c39d9d94 c5e97b00 c68e2df1 c5e97=
b00=20
       c68e2a90 c39d9db4 c39d9d94 0000006c 00000000 ffffffff 00000040 c39d9=
efc=20
Call Trace:   [<c02112f0>] output_maybe_reroute [kernel] 0x0 (0xc39d9d0c)
[<c68e2df1>] udpv6_sendmsg [ipv6] 0x271 (0xc39d9d3c)
[<c68e2a90>] udpv6_getfrag [ipv6] 0x0 (0xc39d9d44)
[<c022bacc>] udp_recvmsg [kernel] 0x5c (0xc39d9dcc)
[<c0231e83>] inet_sendmsg [kernel] 0x33 (0xc39d9e04)
[<c01f195d>] sock_sendmsg [kernel] 0x5d (0xc39d9e18)
[<c01f2b36>] sys_sendmsg [kernel] 0x196 (0xc39d9e5c)
[<c0108d41>] setup_frame [kernel] 0x111 (0xc39d9eb0)
[<c01091cd>] handle_signal [kernel] 0xbd (0xc39d9edc)
[<c0116fb0>] recalc_task_prio [kernel] 0xa0 (0xc39d9eec)
[<c0117e4b>] __wake_up [kernel] 0x4b (0xc39d9f40)
[<c0148098>] pipe_write [kernel] 0x178 (0xc39d9f68)
[<c01f2f6c>] sys_socketcall [kernel] 0x18c (0xc39d9f8c)
[<c01093a3>] system_call [kernel] 0x33 (0xc39d9fc0)
Code: ff 50 0c 5e 85 c0 5f 0f 85 54 fa ff ff 8b 54 24 34 31 ed c7=20


>>EIP; c68d4fd5 <[ipv6]ip6_build_xmit+625/650>   <=3D=3D=3D=3D=3D

>>ebx; c26271a0 <_end+22418a8/6427768>
>>ecx; c5e97bbc <_end+5ab22c4/6427768>
>>edx; 0000a7eb Before first symbol
>>edi; c39d9d94 <_end+35f449c/6427768>
>>ebp; 091dc910 Before first symbol
>>esp; c39d9d04 <_end+35f440c/6427768>

Trace; c02112f0 <output_maybe_reroute+0/10>
Trace; c68e2df1 <[ipv6]udpv6_sendmsg+271/480>
Trace; c68e2a90 <[ipv6]udpv6_getfrag+0/f0>
Trace; c022bacc <udp_recvmsg+5c/260>
Trace; c0231e83 <inet_sendmsg+33/40>
Trace; c01f195d <sock_sendmsg+5d/90>
Trace; c01f2b36 <sys_sendmsg+196/200>
Trace; c0108d41 <setup_frame+111/210>
Trace; c01091cd <handle_signal+bd/100>
Trace; c0116fb0 <recalc_task_prio+a0/1e0>
Trace; c0117e4b <__wake_up+4b/60>
Trace; c0148098 <pipe_write+178/2b0>
Trace; c01f2f6c <sys_socketcall+18c/1b0>
Trace; c01093a3 <system_call+33/40>

Code;  c68d4fd5 <[ipv6]ip6_build_xmit+625/650>
00000000 <_EIP>:
Code;  c68d4fd5 <[ipv6]ip6_build_xmit+625/650>   <=3D=3D=3D=3D=3D
   0:   ff 50 0c                  call   *0xc(%eax)   <=3D=3D=3D=3D=3D
Code;  c68d4fd8 <[ipv6]ip6_build_xmit+628/650>
   3:   5e                        pop    %esi
Code;  c68d4fd9 <[ipv6]ip6_build_xmit+629/650>
   4:   85 c0                     test   %eax,%eax
Code;  c68d4fdb <[ipv6]ip6_build_xmit+62b/650>
   6:   5f                        pop    %edi
Code;  c68d4fdc <[ipv6]ip6_build_xmit+62c/650>
   7:   0f 85 54 fa ff ff         jne    fffffa61 <_EIP+0xfffffa61>
Code;  c68d4fe2 <[ipv6]ip6_build_xmit+632/650>
   d:   8b 54 24 34               mov    0x34(%esp,1),%edx
Code;  c68d4fe6 <[ipv6]ip6_build_xmit+636/650>
  11:   31 ed                     xor    %ebp,%ebp
Code;  c68d4fe8 <[ipv6]ip6_build_xmit+638/650>
  13:   c7 00 00 00 00 00         movl   $0x0,(%eax)


Machine/OS info:
Linux binhex.EU.org 2.4.22-1.2174.nptl #1 Wed Feb 18 14:02:36 EST 2004 i586=
 i586 i386 GNU/Linux
=20
Gnu C                  3.3.2
Gnu make               3.79.1
util-linux             2.11y
mount                  2.11y
modutils               2.4.25
e2fsprogs              1.34
reiserfsprogs          3.6.8
quota-tools            3.06.
PPP                    2.4.1
isdn4k-utils           3.3
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 2.0.17
Net-tools              1.60
Kbd                    1.08
Sh-utils               5.0
Modules Loaded         nls_iso8859-1 autofs 3c59x ipv6 ipt_REJECT iptable_f=
ilter ip_tables ext3 jbd loop lvm-mod

processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 5
model		: 8
model name	: AMD-K6(tm) 3D processor
stepping	: 12
cpu MHz		: 350.805
cache size	: 64 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr mce cx8 pge mmx syscall 3dnow k6_mtrr
bogomips	: 699.59

nls_iso8859-1           3484  12 (autoclean)
autofs                 11156   0 (autoclean) (unused)
3c59x                  29360   1
ipv6                  173076  -1
ipt_REJECT              3960  19 (autoclean)
iptable_filter          2348   1 (autoclean)
ip_tables              14656   2 [ipt_REJECT iptable_filter]
ext3                   65508   3 (autoclean)
jbd                    47596   3 (autoclean) [ext3]
loop                   10808  36 (autoclean)
lvm-mod                63552   0

Please CC to me, since I'm not on the list.

Best regards,=20
Gu=F0mundur.


--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
| Gu=F0mundur D. Haraldsson               | When you have eliminated the im=
possible,|
| gdh@binhex.EU.org                     | what ever remains, however improb=
able,  |
| http://www.binhex.EU.org/             | must be the truth.			  |
|                                       | - Sherlock Holmes, "The sign of f=
our"	  |
|--------------------------------------------------------------------------=
-------|
| GPG key: lynx -dump http://vlug.eyjar.is/gdh/gpgkey.asc | gpg --import   =
       |
| Key fingerprint =3D DE6D A875 EA92 0699 9B49  8C49 2DBB 76BF ADD4 C933		 =
 |
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
// Spammers will be asphyxiated in pat=E9!

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAiujsLbt2v63UyTMRAq6tAKCjaLnY3FiGxbiwnFSLb7jDrg524ACePu3l
KEKuaSADPEZ44ftcZ7ZQ7qw=
=MYo1
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
