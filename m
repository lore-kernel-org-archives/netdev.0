From: Roland Dreier <roland@topspin.com>
Subject: Re: LLTX and netif_stop_queue
Date: Sun, 19 Dec 2004 14:35:26 -0800
Message-ID: <52fz21ncgh.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1103484675.1050.158.camel@jzny.localdomain> (jamal's message
	of "19 Dec 2004 14:31:15 -0500")
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

    jamal> How about releasing the qlock only when the LLTX transmit
    jamal> lock is grabbed? That should bring it to par with what it
    jamal> was originally.

This seems a little risky.  I can't point to a specific deadlock but
it doesn't seem right on general principles to unlock in a different
order than you nested the locks when acquiring them -- if I understand
correctly, you're suggesting lock(queue_lock), lock(tx_lock),
unlock(queue_lock), unlock(tx_lock).

Thanks,
  Roland
