From: Roland Dreier <roland@topspin.com>
Subject: Re: LLTX and netif_stop_queue
Date: Sun, 19 Dec 2004 15:16:58 -0800
Message-ID: <527jndnaj9.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<52fz21ncgh.fsf@topspin.com>
	<1103497592.1046.235.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1103497592.1046.235.camel@jzny.localdomain> (jamal's message
	of "19 Dec 2004 18:06:32 -0500")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Roland> This seems a little risky.  I can't point to a specific
    Roland> deadlock but it doesn't seem right on general principles
    Roland> to unlock in a different order than you nested the locks
    Roland> when acquiring them -- if I understand correctly, you're
    Roland> suggesting lock(queue_lock), lock(tx_lock),
    Roland> unlock(queue_lock), unlock(tx_lock).

    jamal> There is no deadlock. Thats exactly how things work. Try
    jamal> the patches i posted.

Thinking about it more, I guess it's OK.  I was just think about the
basic general rule that locks need to be acquired/released in LIFO
order to avoid deadlock (eg lock(A), lock(B), unlock(B), unlock(A)).

However in this case unlocking queue_lock after acquiring the driver's
tx_lock seems to be OK because the driver does a trylock on tx_lock in
the xmit path, so it can't deadlock.  At worst the trylock will just
fail to get the lock.

Thanks,
  Roland
