From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Thu, 30 Sep 2004 11:41:07 -0700
Sender: openib-general-bounces@openib.org
Message-ID: <521xgj1tx8.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<52r7onc8ev.fsf@topspin.com>
	<20040927215244.697aaa02.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040927215244.697aaa02.davem@davemloft.net> (David S.
	Miller's message of "Mon, 27 Sep 2004 21:52:44 -0700")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> I think you might learn something by having a look at what
    David> net/atm/clip.c is doing, it creates it's own neighbour
    David> layer for CLIP ATM neighbours.  It is in a similar boat to
    David> your IPoIB stuff.

Thanks, this suggestion was very helpful.  I think I'm making
progress.  Now I know my next question :)

CLIP ATM is a little different from IPoIB in that it completely
replaces the ARP layer with its own ARP daemon.  For IPoIB I don't
want to reinvent the ARP and ND code -- I just want to add a secondary
lookup after the response comes back.  I think I have an idea of how
to do that and then stash the information in the struct neighbour, so
that my hard_start_xmit method can get it from skb->dst (ala clip.c).

However, it seems that broadcast ARP packets have skb->dst == NULL.
Is it safe for me to assume that packets with skb->dst == NULL are
broadcast packets?  Will multicast packets have a non-NULL dst?

Thanks,
  Roland
