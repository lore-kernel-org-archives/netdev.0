From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 17:06:08 +0800
Message-ID: <2375c9f90910190206k67dece39i34f484e0645254b9@mail.gmail.com>
References: <4ADC010C.5070809@hitachi.com>
	 <2375c9f90910190002m372edafq9a4c95d754640487@mail.gmail.com>
	 <4ADC2A1D.2090303@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com, masanori.yoshida.tv@hitachi.com
To: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f202.google.com ([209.85.221.202]:57990 "EHLO
	mail-qy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbZJSJGF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 05:06:05 -0400
In-Reply-To: <4ADC2A1D.2090303@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 4:58 PM, Tomoki Sekiyama
<tomoki.sekiyama.qu@hitachi.com> wrote:
> Hi, thanks for testing!
>
> Am=C3=A9rico Wang wrote:
>> On Mon, Oct 19, 2009 at 2:02 PM, Tomoki Sekiyama
>> <tomoki.sekiyama.qu@hitachi.com> wrote:
>>> Hi,
>>> I found a deadlock bug in UNIX domain socket, which makes able to D=
oS
>>> attack against the local machine by non-root users.
>>>
>>> How to reproduce:
>>> 1. Make a listening AF_UNIX/SOCK_STREAM socket with an abstruct
>>> =C2=A0 =C2=A0namespace(*), and shutdown(2) it.
>>> =C2=A02. Repeat connect(2)ing to the listening socket from the othe=
r sockets
>>> =C2=A0 =C2=A0until the connection backlog is full-filled.
>>> =C2=A03. connect(2) takes the CPU forever. If every core is taken, =
the
>>> =C2=A0 =C2=A0system hangs.
>>>
>>> PoC code: (Run as many times as cores on SMP machines.)
>
> Sorry for my ambiguous explanation ...
>
>> Interesting...
>>
>> I tried this with the following command:
>>
>> % for i in `seq 1 $(grep processor -c /proc/cpuinfo)`;
>> do ./unix-socket-dos-exploit; echo "=3D=3D=3D=3D=3D$i=3D=3D=3D=3D";d=
one
> <snip>
>> My system doesn't hang at all.
>>
>> Am I missing something?
>>
>> Thanks!
>
> You should run the ./unix-socket-dos-exploit concurrently, like below=
:
>
> for i in {1..4} ; do ./unix-socket-dos-exploit & done
>
> # For safety reason, the PoC code stops in 15 seconds by alarm(15).

Hmm, you are right.

My system hangs for 10 or more seconds after I did what you said.
Confirmed.

Thanks!
