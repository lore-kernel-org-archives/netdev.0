From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at virtual
 address 000000b0
Date: Thu, 18 Oct 2007 13:22:20 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710181320170.12701@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0710170833071.21430@bizon.gios.gov.pl>
 <4715B26E.20302@cosmosbay.com> <Pine.LNX.4.64.0710171018470.21430@bizon.gios.gov.pl>
 <4715E60E.3020401@cosmosbay.com> <Pine.LNX.4.64.0710171250480.21430@bizon.gios.gov.pl>
 <47161415.1060808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-135843367-1192706540=:12701"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:58563 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050AbXJRLWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:22:50 -0400
In-Reply-To: <47161415.1060808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-135843367-1192706540=:12701
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 17 Oct 2007, Eric Dumazet wrote:

> Krzysztof Oledzki a =E9crit :
>>=20
>>=20
>> On Wed, 17 Oct 2007, Eric Dumazet wrote:
>>=20
>>> Krzysztof Oledzki a =E9crit :
>>>>=20
>>>>=20
>>>> On Wed, 17 Oct 2007, Eric Dumazet wrote:
>>>>=20
>>>>> Krzysztof Oledzki a =E9crit :
>>>>>> Hello,
>>>>>>=20
>>>>>> Today I found in my logs:
>>>>>>=20
>>>>>> BUG: unable to handle kernel NULL pointer dereference at virtual=20
>>>>>> address 000000b0
>>>>>>  printing eip:
>>>>>> 78395f65
>>>>>> *pde =3D 00000000
>>>>>> Oops: 0000 [#1]
>>>>>> PREEMPT SMP
>>>>>> CPU:    0
>>>>>> EIP:    0060:[<78395f65>]    Not tainted VLI
>>>>>> EFLAGS: 00210286   (2.6.22.9 #1)
>>>>>> EIP is at __ip_route_output_key+0x412/0x722
>>>>>> eax: 80000000   ebx: 00000000   ecx: 5dd2b1c3   edx: 00000000
>>>>>> esi: 00000000   edi: d44c7e30   ebp: ec8c4980   esp: d44c7ddc
>>>>>> ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
>>>>>> Process smtpd (pid: 12479, ti=3Dd44c6000 task=3D9e759510 task.ti=3Dd=
44c6000)
>>>>>> Stack: d44c7e7c d44c7e7c d44c7eb8 00000000 d44c7e7c 00000000 0000000=
0=20
>>>>>> 00000005
>>>>>>        00000000 ffffffff 5dd2b1c3 00000000 00000000 00000000 0000000=
0=20
>>>>>> 00000000
>>>>>>        00000000 00000000 00000000 00000000 00000000 00030000 0000000=
0=20
>>>>>> d44c7e7c
>>>>>> Call Trace:
>>>>>>  [<78396280>] ip_route_output_flow+0xb/0x3e
>>>>>>  [<783b2b29>] ip4_datagram_connect+0x1c9/0x308
>>>>>>  [<783ba70a>] inet_dgram_connect+0x45/0x4e
>>>>>>  [<7837135e>] sys_connect+0x72/0x9c
>>>>>>  [<78371607>] sock_map_fd+0x41/0x4a
>>>>>>  [<7840d1b1>] _spin_lock+0x33/0x3e
>>>>>>  [<7840d623>] _spin_unlock+0x25/0x3b
>>>>>>  [<78371607>] sock_map_fd+0x41/0x4a
>>>>>>  [<78372792>] sys_socketcall+0x8f/0x242
>>>>>>  [<7813e99c>] trace_hardirqs_on+0x122/0x14c
>>>>>>  [<78103dc6>] sysenter_past_esp+0x8f/0x99
>>>>>>  [<78103d96>] sysenter_past_esp+0x5f/0x99
>>>>>>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>>>>>> Code: fa e0 00 00 00 75 07 c6 44 24 56 05 eb 14 81 fa f0 00 00 00 0f=
 84=20
>>>>>> e1 02 00 00 84 c0 0f 84 d9 02 00 00 8b 44 24 0c 0d 00 00 00 80 <f6> =
86=20
>>>>>> b0 00 00 00 08 0f 44 44 24 0c 89 44 24 0c b8 01 00 00 00
>>>>>> EIP: [<78395f65>] __ip_route_output_key+0x412/0x722 SS:ESP=20
>>>>>> 0068:d44c7ddc
>>>>>>=20
>>>>>> Shortly before it there was:
>>>>>> Oct 17 07:17:55 cougar postfix/master[3400]: warning: process=20
>>>>>> /usr/lib/postfix/smtpd pid 12479 killed by signal 11
>>>>>>=20
>>>>>> Best regards,
>>>>>>=20
>>>>>>
>>>>>>                 Krzysztof Ol=EAdzki
>>>>>=20
>>>>> Hello Krzysztof
>>>>>=20
>>>>> Could you give us some details about this ? kernel version at least.
>>>>=20
>>>> Yes, I was little to hurry sending this bug report. Anyway, it is=20
>>>> 2.6.22.9 like mentioned in the oops: EFLAGS: 00210286 (2.6.22.9 #1)
>>>>=20
>>>>> (you could for example take a look at REPORTING-BUGS, or run
>>>>> scripts/ver_linux)
>>>>=20
>>>> Linux cougar 2.6.22.9 #1 SMP PREEMPT Wed Oct 3 10:24:19 CEST 2007 i686=
=20
>>>> Intel(R) Pentium(R) D CPU 3.20GHz GenuineIntel GNU/Linux
>>>>=20
>>>> Gnu C                  4.1.2
>>>> Gnu make               3.81
>>>> binutils               2.17
>>>> util-linux             2.12r
>>>> mount                  2.12r
>>>> module-init-tools      3.2.2
>>>> e2fsprogs              1.40.2
>>>> Linux C Library        > libc.2.5
>>>> Dynamic linker (ldd)   2.5
>>>> Procps                 3.2.7
>>>> Net-tools              1.60
>>>> Kbd                    1.12
>>>> Sh-utils               6.9
>>>>=20
>>>=20
>>> Yes indeed, version was on your initial report.
>>>=20
>>> It seems this kernel is unusual (VMSPLIT_2G_OPT instead of stdandard=20
>>> VMSPLIT_3G), any chance you provide full .config ?
>>=20
>> Attached, both .config and dmesg.
>>=20
>
> Hum, you are using IPT_TPROXY thing, which is not in linux-2.6.22.9

It is only compiled in, not used at the moment.

> I have no idea how this can taint the kernel, since you provide no=20
> information.
>
> Try to reproduce the problem with a genuine kernel.

OK. Thank you.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-135843367-1192706540=:12701--
