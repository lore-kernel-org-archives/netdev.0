From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 21:07:49 +0100
Message-ID: <45EDCA15.4060704@cosmosbay.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com> <200703061142.00261.dada1@cosmosbay.com> <45EDB55C.2080803@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39558 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbXCFUIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 15:08:16 -0500
In-Reply-To: <45EDB55C.2080803@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Howard Chu a =E9crit :
> Eric Dumazet wrote:
>> On Tuesday 06 March 2007 10:22, Howard Chu wrote:
>>
>>> It's a combination of 2MSL and /proc/sys/net/ipv4/ip_local_port_ran=
ge -
>>> on my system the default port range is 32768-61000. That means if I=
 use
>>> up 28232 ports in less than 2MSL then everything stops. netstat wil=
l
>>> show that all the available port numbers are in TIME_WAIT state. An=
d
>>> this is particularly bad because while waiting for the timeout, I c=
an't
>>> initiate any new outbound connections of any kind at all - telnet, =
ssh,
>>> whatever, you have to wait for at least one port to free up.
>>> (Interesting denial of service there....)
>>>
>>> Granted, I was running my test on 2.6.18, perhaps 2.6.21 behaves
>>> differently.
>>
>> Could you try this attached program and tell me whats happen ?
>>
>> $ gcc -O2 -o socktest socktest.c -lpthread
>> $ time ./socktest -n 100000
>> nb_conn=3D99999 nb_accp=3D99999
>>
>> real    0m5.058s
>> user    0m0.212s
>> sys     0m4.844s
>>
>> (on my small machine, dell d610 :) )
>=20
> On my Asus laptop (2GHz Pentium M) the first time I ran it it complet=
ed=20
> in about 51 seconds, with no errors. I then copied it to another mach=
ine=20
> and started it up there, and got connect errors right away. I then we=
nt=20
> back to my laptop and ran it again, and got errors that time.
>=20
> This is the laptop run with errors:
> viola:~/src> uname -a
> Linux viola 2.6.18.2-34-default #1 SMP Mon Nov 27 11:46:27 UTC 2006 i=
686=20
> i686 i386 GNU/Linux
> viola:~/src> time ./socktest -n 1000000
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> nb_conn=3D993757 nb_accp=3D993757
> 1.408u 88.649s 1:42.76 87.6%    0+0k 0+0io 0pf+0w
>=20
> This is my other system, an AMD X2 3800+ (dual core)
> mandolin:~/src> uname -a
> Linux mandolin 2.6.18.3SMP #9 SMP Sat Nov 25 10:08:51 PST 2006 x86_64=
=20
> x86_64 x86_64 GNU/Linux
> mandolin:~/src> gcc -O2 -o socktest socktest.c -lpthread
> mandolin:~/src> time ./socktest -n 1000000
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> connect error 99
> nb_conn=3D957088 nb_accp=3D957088
> 1.012u 630.991s 5:18.05 198.7%  0+0k 0+0io 0pf+0w

Let me see, any chance you can try the prog on 2.6.20 ?

If not, please send :

grep . /proc/sys/net/ipv4/*

Thank you
