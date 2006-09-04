From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.18-rc5 with GRE, iptables and Speedtouch ADSL, PPP over ATM
Date: Mon, 4 Sep 2006 12:44:14 +0400
Message-ID: <20060904084414.GA19793@ms2.inr.ac.ru>
References: <m3odty57gf.fsf@defiant.localdomain> <20060903111507.GA12580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:20964 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751179AbWIDIqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 04:46:03 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060903111507.GA12580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This path obviously breaks assumption 1) and therefore can lead to ABBA
> dead-locks.

Yes...


> I've looked at the history and there seems to be no reason for the lock
> to be held at all in dev_watchdog_up.  The lock appeared in day one and
> even there it was unnecessary.

Seems, it serializes mod_timer and timer handler to keep timer
in predictable state. Maybe, this is not necessary. A priori, it is required.

Note that in dev_watchdog_down() queue_lock is released before
taking xmit_lock. Probably, this is the thing which was supposed
to be done in dev_watchdog_up() too.

Alexey

-- 
VGER BF report: U 0.46385
