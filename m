From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will
 cause to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Wed, 07 May 2014 09:28:39 -0700
Message-ID: <1399480119.15399.163.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	 <CADVnQy=1WdUT1xHX04uBQtROwOYDZF6idw1Qx2o2DM13kWWjFQ@mail.gmail.com>
	 <CANHbGWsqBZEw0-6A0zE6PrSUF1osbN86mcYxjo9Z4V6WWyXTww@mail.gmail.com>
	 <1399479939.15399.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>
To: V JobNickname <workofv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34519 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaEGQ2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 12:28:41 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so1260072pdi.9
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 09:28:40 -0700 (PDT)
In-Reply-To: <1399479939.15399.160.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-07 at 09:25 -0700, Eric Dumazet wrote:

> I am wondering if you are asking for git bisect maybe ?
> 
> https://www.kernel.org/pub/software/scm/git/docs/git-bisect.html
> 
> But in this case I am not sure it will help.
> 
> An old bug can sit for years, and finally be discovered when some other
> change is done.


Yes, following code is rather crappy :

        if (priv->tx_coal_frames > priv->tx_count_frames) {
                priv->hw->desc->clear_tx_ic(desc);
                priv->xstats.tx_reset_ic_bit++;
                mod_timer(&priv->txtimer,
                          STMMAC_COAL_TIMER(priv->tx_coal_timer));
        } else
                priv->tx_count_frames = 0;

40 ms is already a big timer, and restarting it every time another frame
is queued is a total disaster.
