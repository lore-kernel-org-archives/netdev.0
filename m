From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] IrDA 2.6.28 bug fix
Date: Sun, 14 Dec 2008 23:08:37 -0800 (PST)
Message-ID: <20081214.230837.169487041.davem@davemloft.net>
References: <20081215015729.587697008@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20081215015729.587697008-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Date: Mon, 15 Dec 2008 02:57:29 +0100

> This is a 9 patches series for IrDA, against your net-2.6 tree.
> This is an attempt to fix kernel.bugzilla.org bug #11795, where we noticed
> skb->cb could be altered once submitted to dev_queue_xmit. Since IrDA is using
> this callback to pass per-skb information, we are now stuffing it in front of
> skb->data, after allocating the right headroom.
> 
> Another solution would be to play with the IrDA physical header and skb_pull
> our skbs whenever we are physically transmitting the data.

Hi Sam.

I appreciate you working on this.

But I there are two issues here:

1) There is no way I can put a series of 9 invasive patches like these
   so late into 2.6.28

   If we need to fix it in 2.6.28 it'd need to be a 5 to 10 line
   change at most, even if hackish, before I could seriously consider
   it.

2) Just like you can't claim ownership to skb->cb after dev_queue_xmit(),
   you just as equally can't claim ownership to areas in front of
   skb->data either.

I'm pretty sure we discussed how #2 wouldn't work for this problem.

I understand you need a way to pass information, but you're trying to
do it using things the IRDA (nor any other) stack does not own across
a dev_queue_xmit() invocation.

Furthermore, device layer schemes that try to use some shared
part of the skb for their communication is frail, and a good
way to see how frail it is is to consider how encapsulation of
such device types within themselves might be made to work.

You can't do it with skb->cb[] private storage, and you doubly can't
do it by sneaking things in front of skb->data because that's where
the encapsulated protocol headers would go.

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
