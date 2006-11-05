From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [sungem] proposal for a new locking strategy
Date: Sun, 5 Nov 2006 18:28:33 +0100
Message-ID: <5cac192f0611050928w50127396l2a88978bf97b2bff@mail.gmail.com>
References: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
	 <1162731940.28571.245.camel@localhost.localdomain>
	 <5cac192f0611050517q297f5b04w7931788f6dfef3fc@mail.gmail.com>
	 <20061105090254.66710154@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:4283 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161415AbWKER2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 12:28:35 -0500
Received: by nf-out-0910.google.com with SMTP id c2so436404nfe
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 09:28:34 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061105090254.66710154@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You could also just use net_tx_lock() now.

You mean netif_tx_lock()?

Thanks for letting me know about that function. Yes, I may need it.
tg3 and bnx2 use it to wake up the transmit queue:

         if (unlikely(netif_queue_stopped(tp->dev) &&
                      (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))) {
                 netif_tx_lock(tp->dev);
                 if (netif_queue_stopped(tp->dev) &&
                     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))
                         netif_wake_queue(tp->dev);
                 netif_tx_unlock(tp->dev);
         }

2.6.17 didn't use it. Was it a bug?

Thanks,
-- 
Eric
