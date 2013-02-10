From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Sat, 09 Feb 2013 17:16:02 -0800
Message-ID: <1360458962.6696.38.camel@edumazet-glaptop>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
	 <20130208.145728.1110053781319882182.davem@davemloft.net>
	 <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
	 <20130208.151523.798634382725569230.davem@davemloft.net>
	 <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
	 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:36590 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760894Ab3BJBQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 20:16:07 -0500
Received: by mail-da0-f53.google.com with SMTP id w3so22748dad.40
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 17:16:05 -0800 (PST)
In-Reply-To: <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-09 at 21:27 +0100, Javier Domingo wrote:
> Can you tell me something about the traces I introduced?
> 
> I tried to insert the trace the cleanest way possible. I patched
> dev.c, in the measurement places and tried to make the module the more
> independent I could. It makes the measure with sched_clock() and in
> each round, it sums up the work done.
> 
> I have supposed that that softirq is just for capturing packets, so
> that is why I asked my first question,

Seems pretty easy to understand to me.

A network device receives and transmits packets.

n->poll() call done in net_rx_action() can both :

- Receive packets
- Perform the TX completion for most devices (some of them still
  use a hard IRQ driven TX completion path)

The return value is only about receive part.

(The TX completion is not limited by a per round quota)
