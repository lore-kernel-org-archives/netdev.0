From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Fri, 22 Feb 2013 10:32:22 +0100
Message-ID: <CALZVapmKbqcamTYTEhoerRUPpjsaLJqoTo84Fqmz+aUWWTmh2g@mail.gmail.com>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
 <20130208.145728.1110053781319882182.davem@davemloft.net> <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
 <20130208.151523.798634382725569230.davem@davemloft.net> <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
 <1360458962.6696.38.camel@edumazet-glaptop> <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
 <1360484188.20362.11.camel@edumazet-glaptop> <CALZVapm1evE6rOgNkJapu9VboA6OojKGJ-UhRhZ26J0A+k4nmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:39537 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324Ab3BVJcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 04:32:43 -0500
Received: by mail-vb0-f45.google.com with SMTP id p1so282550vbi.18
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 01:32:42 -0800 (PST)
In-Reply-To: <CALZVapm1evE6rOgNkJapu9VboA6OojKGJ-UhRhZ26J0A+k4nmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Which is the reason for that in the poll function, not only some
drivers have that tx completion (I suppose it is to free resources),
but also to send packets in that routine?

In e1000e, I have found that it frees resources used in tx, with the
e1000_clean_tx_irq, and also, although the tx completion is first, it
executes the rx routine.

On the other hand, tg3 driver not only does the tx resources free but
also sends packets in that time, and may return from the poll thought
it might not have done rx work in the net_rx_action routine.

Why is this like that? I mean, why all the tx is done *before* the rx
thread, thought it may not do any rx work (in tg3) ?

I hope you can help me to understand the reasons,

Javier Domingo
