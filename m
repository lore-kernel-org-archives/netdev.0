From: Chitrapu_Kishore@emc.com
Subject: oops in tcp_ipv4.c
Date: Wed, 22 Oct 2003 17:41:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <F483EA17AA200F4CB6812656E66FC68E54F92B@corpusmx5.corp.emc.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C398E5.3EEBD0F8"
Cc: Chitrapu_Kishore@emc.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C398E5.3EEBD0F8
Content-Type: text/plain

I have a panic on machines which have very high rate of incoming TCP
connections. 
This panic occurs with 2.4.19 with SuSE patches applied to it. Specs:
Pentium III (Coppermine), 1GHz, with memory = 515356 kB

cat /proc/modules gives the following:
ppp_generic            20576   0
slhc                    6724   0 [ppp_generic]
af_packet              11432   0 (autoclean)
eepro100               22136   3 (autoclean)
ipt_state               1112  14 (autoclean)
ip_conntrack           21176   1 (autoclean) [ipt_state]
ipt_LOG                 4280   8 (autoclean)
iptable_filter          2444   1 (autoclean)
ip_tables              14720   3 [ipt_state ipt_LOG iptable_filter]
rtc                     8684   0 (autoclean)

Following is the output from ksymoops:
------------
Unable to handle kernel paging request at virtual address 0013c1da
c01f8bcd
*pde = 00000000
Oops: 0000 2.4.19-prod-sles-ded8470bc8d929ffca7ec0daf42b93d6 #1 Thu Oct 9
05:10:58 EDT 2003
CPU: 0
EIP: 0010:[<c01f8bcd>]  Tainted: P
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010246
eax: 03049a34   ebx:      0013c192     ecx: 0013c192       edx:  00000000
esi: c3007e98   edi:      00000c00     ebp: 00000096       esp:  c3007e64
ds:  0018       es: 0018      ss: 0018
Process netstat (pid: 11340, stackpage=c3007000)
Stack: 0013c192 c3007e98 c01f8fa1 0013c192 c3007e98 0000000e 00000000
00000c00
       c0128bf0 00000960 00003ca5 0000000e 0000012c 33312020 3030202a
42303430
       303a3037 20303031 36303030 34324431 3630303a 44442035 30303020
30303030
Call Trace: [<c01f8fa1>] [<c0128bf0>] [<c01303c4>] [<c01561b4>] [<c0136d46>]
[<c0108933>]
Code: 8b 59 48 29 c3 0f b7 41 08 0f 48 da 86 c4 0f b7 51 22 86 d6


>>EIP; c01f8bcd <get_timewait_sock+d/70>   <=====

>>esi; c3007e98 <[ip_conntrack].bss.end+83306d/eaf235>
>>esp; c3007e64 <[ip_conntrack].bss.end+833039/eaf235>

Trace; c01f8fa1 <tcp_get_info+371/440>
Trace; c0128bf0 <filemap_nopage+0/210>
Trace; c01303c4 <__alloc_pages+74/2e0>
Trace; c01561b4 <proc_file_read+94/1c0>
Trace; c0136d46 <sys_read+96/f0>
Trace; c0108933 <system_call+33/38>

Code;  c01f8bcd <get_timewait_sock+d/70>
00000000 <_EIP>:
Code;  c01f8bcd <get_timewait_sock+d/70>   <=====
   0:   8b 59 48                  mov    0x48(%ecx),%ebx   <=====
Code;  c01f8bd0 <get_timewait_sock+10/70>
   3:   29 c3                     sub    %eax,%ebx
Code;  c01f8bd2 <get_timewait_sock+12/70>
   5:   0f b7 41 08               movzwl 0x8(%ecx),%eax
Code;  c01f8bd6 <get_timewait_sock+16/70>
   9:   0f 48 da                  cmovs  %edx,%ebx
Code;  c01f8bd9 <get_timewait_sock+19/70>
   c:   86 c4                     xchg   %al,%ah
Code;  c01f8bdb <get_timewait_sock+1b/70>
   e:   0f b7 51 22               movzwl 0x22(%ecx),%edx
Code;  c01f8bdf <get_timewait_sock+1f/70>
  12:   86 d6                     xchg   %dl,%dh

 <0> Kernel panic: Aiee, killing interrupt handler!
----------------------

Looks tcp_ehash[i+tcp_ehash_size] which accomodates all the timewait socks
has been corrupted by the time procfs read happens.

Is this panic already reported if so is there patch available for this.

Thanks,
-KC

PS: Please copy me as I am not the list.



------_=_NextPart_001_01C398E5.3EEBD0F8
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2657.73">
<TITLE>oops in tcp_ipv4.c</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2 FACE=3D"Arial">I have a panic on machines which have =
very high rate of incoming TCP connections. </FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">This panic occurs with 2.4.19 with =
SuSE patches applied to it. Specs: Pentium III (Coppermine), 1GHz, with =
memory =3D 515356 kB</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">cat /proc/modules gives the =
following:</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">ppp_generic&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 20576&nbsp;&nbsp; 0</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">slhc&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
6724&nbsp;&nbsp; 0 [ppp_generic]</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">af_packet&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 11432&nbsp;&nbsp; 0 (autoclean)</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">eepro100&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 22136&nbsp;&nbsp; 3 =
(autoclean)</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">ipt_state&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1112&nbsp; 14 (autoclean)</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">ip_conntrack&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 21176&nbsp;&nbsp; 1 (autoclean) [ipt_state]</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">ipt_LOG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4280&nbsp;&nbsp; 8 =
(autoclean)</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">iptable_filter&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 2444&nbsp;&nbsp; 1 (autoclean)</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">ip_tables&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 14720&nbsp;&nbsp; 3 [ipt_state ipt_LOG =
iptable_filter]</FONT>
<BR><FONT SIZE=3D2 =
FACE=3D"Arial">rtc&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
8684&nbsp;&nbsp; 0 (autoclean)</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Following is the output from =
ksymoops:</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">------------</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Unable to handle kernel paging =
request at virtual address 0013c1da</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">c01f8bcd</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">*pde =3D 00000000</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Oops: 0000 =
2.4.19-prod-sles-ded8470bc8d929ffca7ec0daf42b93d6 #1 Thu Oct 9 05:10:58 =
EDT 2003</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">CPU: 0</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">EIP: 0010:[&lt;c01f8bcd&gt;]&nbsp; =
Tainted: P</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Using defaults from ksymoops -t =
elf32-i386 -a i386</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">EFLAGS: 00010246</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">eax: 03049a34&nbsp;&nbsp; =
ebx:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0013c192&nbsp;&nbsp;&nbsp;&nbsp; =
ecx: 0013c192&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; edx:&nbsp; =
00000000</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">esi: c3007e98&nbsp;&nbsp; =
edi:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00000c00&nbsp;&nbsp;&nbsp;&nbsp; =
ebp: 00000096&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; esp:&nbsp; =
c3007e64</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">ds:&nbsp; =
0018&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; es: =
0018&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ss: 0018</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Process netstat (pid: 11340, =
stackpage=3Dc3007000)</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Stack: 0013c192 c3007e98 c01f8fa1 =
0013c192 c3007e98 0000000e 00000000 00000c00</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
c0128bf0 00000960 00003ca5 0000000e 0000012c 33312020 3030202a 42303430<=
/FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
303a3037 20303031 36303030 34324431 3630303a 44442035 30303020 =
30303030</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Call Trace: [&lt;c01f8fa1&gt;] =
[&lt;c0128bf0&gt;] [&lt;c01303c4&gt;] [&lt;c01561b4&gt;] =
[&lt;c0136d46&gt;] [&lt;c0108933&gt;]</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code: 8b 59 48 29 c3 0f b7 41 08 0f =
48 da 86 c4 0f b7 51 22 86 d6</FONT>
</P>
<BR>

<P><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt;EIP; c01f8bcd =
&lt;get_timewait_sock+d/70&gt;&nbsp;&nbsp; &lt;=3D=3D=3D=3D=3D</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt;esi; c3007e98 =
&lt;[ip_conntrack].bss.end+83306d/eaf235&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt;esp; c3007e64 =
&lt;[ip_conntrack].bss.end+833039/eaf235&gt;</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Trace; c01f8fa1 =
&lt;tcp_get_info+371/440&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Trace; c0128bf0 =
&lt;filemap_nopage+0/210&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Trace; c01303c4 =
&lt;__alloc_pages+74/2e0&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Trace; c01561b4 =
&lt;proc_file_read+94/1c0&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Trace; c0136d46 =
&lt;sys_read+96/f0&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Trace; c0108933 =
&lt;system_call+33/38&gt;</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bcd =
&lt;get_timewait_sock+d/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">00000000 &lt;_EIP&gt;:</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bcd =
&lt;get_timewait_sock+d/70&gt;&nbsp;&nbsp; &lt;=3D=3D=3D=3D=3D</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; 0:&nbsp;&nbsp; 8b 59 =
48&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mov&nbsp;&nbsp;&nbsp; =
0x48(%ecx),%ebx&nbsp;&nbsp; &lt;=3D=3D=3D=3D=3D</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bd0 =
&lt;get_timewait_sock+10/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; 3:&nbsp;&nbsp; 29 =
c3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
sub&nbsp;&nbsp;&nbsp; %eax,%ebx</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bd2 =
&lt;get_timewait_sock+12/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; 5:&nbsp;&nbsp; 0f b7 41 =
08&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; movzwl 0x8(%ecx),%eax</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bd6 =
&lt;get_timewait_sock+16/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; 9:&nbsp;&nbsp; 0f 48 =
da&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cmovs&nbsp; %edx,%ebx</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bd9 =
&lt;get_timewait_sock+19/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; c:&nbsp;&nbsp; 86 =
c4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; xchg&nbsp;&nbsp; =
%al,%ah</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bdb =
&lt;get_timewait_sock+1b/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; e:&nbsp;&nbsp; 0f b7 51 =
22&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; movzwl 0x22(%ecx),%edx</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Code;&nbsp; c01f8bdf =
&lt;get_timewait_sock+1f/70&gt;</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp; 12:&nbsp;&nbsp; 86 =
d6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; xchg&nbsp;&nbsp; =
%dl,%dh</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&lt;0&gt; Kernel panic: Aiee, =
killing interrupt handler!</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">----------------------</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Looks tcp_ehash[i+tcp_ehash_size] =
which accomodates all the timewait socks has been corrupted by the time =
procfs read happens.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Is this panic already reported if so =
is there patch available for this.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Thanks,</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">-KC</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">PS: Please copy me as I am not the =
list.</FONT>
</P>
<BR>

</BODY>
</HTML>
------_=_NextPart_001_01C398E5.3EEBD0F8--
