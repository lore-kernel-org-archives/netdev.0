From: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 17:54:04 +0900
Message-ID: <4ADC292C.8010608@hitachi.com>
References: <4ADC010C.5070809@hitachi.com> <2375c9f90910190002m372edafq9a4c95d754640487@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:53593 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534AbZJSIyG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 04:54:06 -0400
In-Reply-To: <2375c9f90910190002m372edafq9a4c95d754640487@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, thanks for testing!

Am=C3=A9rico Wang wrote:
> On Mon, Oct 19, 2009 at 2:02 PM, Tomoki Sekiyama
> <tomoki.sekiyama.qu@hitachi.com> wrote:
>> Hi,
>> I found a deadlock bug in UNIX domain socket, which makes able to Do=
S
>> attack against the local machine by non-root users.
>>
>> How to reproduce:
>> 1. Make a listening AF_UNIX/SOCK_STREAM socket with an abstruct
>>    namespace(*), and shutdown(2) it.
>>  2. Repeat connect(2)ing to the listening socket from the other sock=
ets
>>    until the connection backlog is full-filled.
>>  3. connect(2) takes the CPU forever. If every core is taken, the
>>    system hangs.
>>
>> PoC code: (Run as many times as cores on SMP machines.)

Sorry for my ambiguous explanation ...

> Interesting...
>=20
> I tried this with the following command:
>=20
> % for i in `seq 1 $(grep processor -c /proc/cpuinfo)`;
> do ./unix-socket-dos-exploit; echo "=3D=3D=3D=3D=3D$i=3D=3D=3D=3D";do=
ne
<snip>
> My system doesn't hang at all.
>=20
> Am I missing something?
>
> Thanks!

You should run the ./unix-socket-dos-exploit concurrently, like below:

for i in {1..4} ; do ./unix-socket-dos-exploit & done

# For safety reason, the PoC code stops in 15 seconds by alarm(15).

--=20
Tomoki Sekiyama
Linux Technology Center
Hitachi, Ltd., Systems Development Laboratory
E-mail: tomoki.sekiyama.qu@hitachi.com
