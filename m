From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Sun, 10 Feb 2013 00:16:28 -0800
Message-ID: <1360484188.20362.11.camel@edumazet-glaptop>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
	 <20130208.145728.1110053781319882182.davem@davemloft.net>
	 <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
	 <20130208.151523.798634382725569230.davem@davemloft.net>
	 <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
	 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
	 <1360458962.6696.38.camel@edumazet-glaptop>
	 <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:48677 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3BJIQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 03:16:31 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so2639736pad.35
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 00:16:31 -0800 (PST)
In-Reply-To: <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post on netdev

On Sun, 2013-02-10 at 04:02 +0100, Javier Domingo wrote:
> Well, that explains why the 0 :D. I was getting nut. Any way, does
> that happen in e1000e or tg3 drivers? If not, then there is still
> without explanation.
> 


The answer is yes.

> Respecting the low numbers, I will do some futher stress tests, but
> this measures where done pinging the computer at 0.001 interval:
> 
> ping -i 0.0001 <computer ip>
> 
> And received packets where at much, 3 per softirq. Also, I tried
> opening an ftp download session but didn't get much high numbers
> (1Gbps link).
> 

Machine is fast enough, thats all.

> When I tried this with the injection done by a dag (hardware injector)
> there were strange results because thought the 0s where explained, the
> were appearing thought the rest of softirqs where about 280+-50.

Have you read this part of net_rx_action() ?

unsigned long time_limit = jiffies + 2;

                /* If softirq window is exhuasted then punt.
                 * Allow this to run for 2 jiffies since which will allow
                 * an average latency of 1.5/HZ.
                 */
                if (unlikely(budget <= 0 || time_after(jiffies, time_limit)))
                        goto softnet_break;

This means your machine handles 280+50 packets per 1.5/HZ

(Plus the hidden TX completions...)
