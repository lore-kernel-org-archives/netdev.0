From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 22:58:13 +0100
Message-ID: <4B22C075.2020902@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Constantine <kevin.constantine@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43301 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761510AbZLKV6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 16:58:09 -0500
In-Reply-To: <4B22BEAB.1080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/12/2009 22:50, Kevin Constantine a =E9crit :
> On 12/11/2009 01:39 PM, Eric Dumazet wrote:
>> Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
>>> Hey Everyone-
>>>
>>> I've been playing with an ARM based linuxstamp
>>> http://opencircuits.com/Linuxstamp, and I've been seeing kernel pan=
ics
>>> with both 2.6.28.3, and 2.6.30 within an hour or so of turning the
>>> linuxstamp on.  The stack traces always seem to point at functions
>>> related to networking.  I've pasted a couple of the crash outputs b=
elow.
>>>   The linuxstamp isn't typically doing anything when the crashes oc=
cur,
>>> in fact it'll crash even if I haven't logged in.
>>>
>>> If I ifconfig the interface down, the linuxstamp stays up indefinit=
ely.
>>>   Any pointers in one direction or another would be much appreciate=
d.
>>>
>>> I'm not sure if this is the right audience to help out or if the ar=
m
>>> lists might be better.  But in any event, any help would be really
>>> appreciated.
>>>
>>>
>>> linuxstamp login: Unable to handle kernel paging request at virtual
>>> address 183cb7b0
>>> pgd =3D c0004000
>>> [183cb7b0] *pgd=3D00000000
>>> Internal error: Oops: 0 [#1] PREEMPT
>>> Modules linked in:
>>> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
>>> PC is at 0x183cb7b0
>>> LR is at __udp4_lib_rcv+0x43c/0x72c
>>
>> Could you disassemble your vmlinux file, __udp4_lib_rcv function
>> around LR
>> <c024ff4c>, to see which function was called ? This function then ca=
lled
>> a wrong pointer (0x183cb7b0 not a kernel pointer)
>>
>> Maybe a kernel stack corruption, or bad ram, ...
>=20
> The vmlinux file I'm using has probably changed a number of times sin=
ce
> then.  I'll get a fresh stack trace and disassemble that one.
>=20
> I've has this type of problem with several linuxstamps.  I'm only abl=
e
> to trigger this panic when the linuxstamp is plugged into a cisco
> catalyst gigabit switch.  Plugging it in at home into a consumer grad=
e
> 10/100 switch, the linuxstamp stays up indefinitely.
>=20
> Also worth noting, I'm seeing the error counts in ifconfig increase
> steadily.

Could be an error in NIC driver error path, this is a good point.

>=20
> eth0      Link encap:Ethernet  HWaddr ac:de:48:00:00:01
>           inet addr:172.30.194.255  Bcast:172.30.207.255 Mask:255.255=
=2E240.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:42492 errors:1442 dropped:0 overruns:6 frame:784
>           TX packets:1169 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:3804651 (3.6 MiB)  TX bytes:106728 (104.2 KiB)
>           Interrupt:24 Base address:0xc000
>=20
>=20

Please give us more information, since this platform is not well known =
:)

lsmod
cat /proc/meminfo
cat /proc/cpuinfo
cat /proc/slabinfo  (after more than 2000 error count in ifconfig eth0)
=2E..
