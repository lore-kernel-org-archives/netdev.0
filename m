From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Fri, 22 Feb 2013 06:11:21 -0800
Message-ID: <1361542281.3683.3.camel@edumazet-glaptop>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
	 <20130208.145728.1110053781319882182.davem@davemloft.net>
	 <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
	 <20130208.151523.798634382725569230.davem@davemloft.net>
	 <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
	 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
	 <1360458962.6696.38.camel@edumazet-glaptop>
	 <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
	 <1360484188.20362.11.camel@edumazet-glaptop>
	 <CALZVapm1evE6rOgNkJapu9VboA6OojKGJ-UhRhZ26J0A+k4nmw@mail.gmail.com>
	 <CALZVapmKbqcamTYTEhoerRUPpjsaLJqoTo84Fqmz+aUWWTmh2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57343 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab3BVOL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 09:11:26 -0500
Received: by mail-pa0-f42.google.com with SMTP id kq12so490394pab.29
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 06:11:26 -0800 (PST)
In-Reply-To: <CALZVapmKbqcamTYTEhoerRUPpjsaLJqoTo84Fqmz+aUWWTmh2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-22 at 10:32 +0100, Javier Domingo wrote:
> Which is the reason for that in the poll function, not only some
> drivers have that tx completion (I suppose it is to free resources),
> but also to send packets in that routine?
> 
> In e1000e, I have found that it frees resources used in tx, with the
> e1000_clean_tx_irq, and also, although the tx completion is first, it
> executes the rx routine.
> 
> On the other hand, tg3 driver not only does the tx resources free but
> also sends packets in that time, and may return from the poll thought
> it might not have done rx work in the net_rx_action routine.
> 
> Why is this like that? I mean, why all the tx is done *before* the rx
> thread, thought it may not do any rx work (in tg3) ?

To free memory, so that rx handler gets more chance to be able to
allocate memory, and reuse memory already hot in cpu caches.
