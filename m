From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Sun, 10 Feb 2013 04:02:47 +0100
Message-ID: <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
 <20130208.145728.1110053781319882182.davem@davemloft.net> <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
 <20130208.151523.798634382725569230.davem@davemloft.net> <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com> <1360458962.6696.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:46374 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760958Ab3BJDDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 22:03:08 -0500
Received: by mail-ve0-f180.google.com with SMTP id jx10so4383220veb.11
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 19:03:07 -0800 (PST)
In-Reply-To: <1360458962.6696.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, that explains why the 0 :D. I was getting nut. Any way, does
that happen in e1000e or tg3 drivers? If not, then there is still
without explanation.

Respecting the low numbers, I will do some futher stress tests, but
this measures where done pinging the computer at 0.001 interval:

ping -i 0.0001 <computer ip>

And received packets where at much, 3 per softirq. Also, I tried
opening an ftp download session but didn't get much high numbers
(1Gbps link).

When I tried this with the injection done by a dag (hardware injector)
there were strange results because thought the 0s where explained, the
were appearing thought the rest of softirqs where about 280+-50.

I have done some testing remotelly with a dag, and I will post here
the results after monday when I return to the lab.

I will check meanwhile for the drivers that we use in the lab that
have that tx completion in their polling call.

Thank you,

Javier Domingo


2013/2/10 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sat, 2013-02-09 at 21:27 +0100, Javier Domingo wrote:
>> Can you tell me something about the traces I introduced?
>>
>> I tried to insert the trace the cleanest way possible. I patched
>> dev.c, in the measurement places and tried to make the module the more
>> independent I could. It makes the measure with sched_clock() and in
>> each round, it sums up the work done.
>>
>> I have supposed that that softirq is just for capturing packets, so
>> that is why I asked my first question,
>
> Seems pretty easy to understand to me.
>
> A network device receives and transmits packets.
>
> n->poll() call done in net_rx_action() can both :
>
> - Receive packets
> - Perform the TX completion for most devices (some of them still
>   use a hard IRQ driven TX completion path)
>
> The return value is only about receive part.
>
> (The TX completion is not limited by a per round quota)
>
>
>
