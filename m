From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-11-26
Date: Fri, 2 Dec 2011 18:12:16 +0100
Message-ID: <20111202171216.GA4561@ritirata.org>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
	<20111126.144122.775553783672941660.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111126.144122.775553783672941660.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello David,

On Sat, Nov 26, 2011 at 02:41:22 -0500, David Miller wrote:
[CUT]
> Some things to look into:
> 
> +			if (unlikely(skb_headlen(skb) <
> +					sizeof(struct tt_query_packet) +
> +					tt_len))
> 
> This isn't formatted correctly, all the leading edges should line
> up to the openning parenthesis of the unlikely:
> 
> +			if (unlikely(skb_headlen(skb) <
> +				     sizeof(struct tt_query_packet) +
> +				     tt_len))
> 

Thank you for reporting this issue. We have already prepared a patch which is
going to be sent within the next batch.

> Next, there is a lot of linearization done by the stack, but really the
> thing to do is to make sure that the part you want to look at is
> linear.
> 
> You do this using pskb_may_pull() right before you want to look at some
> headers. It makes sure that, for the length given, that many bytes are
> linear at the head of the skb.
> 

For this issue, we had some problem to understand it.

First of all I think you are referring to patch 08/10, in which I moved a
skb_linearise() operation.

To be sure it is really needed, I backtracked the code flow and noted down any
eventual psbk_may_pull() (or any other linearisation operation). The result is:

=> in batman_skb_recv()
	- pskb_may_pull(2)
  => in recv_tt_query()
  	  - pskb_may_pull(sizeof(header))
	  - skb_linearise()

Actually it seems we haven't any useless linearisation.
Would you mind explain us where you actually found the problem, please?

It might also be that I misunderstood your advice.

Thank you.


Best Regards,

-- 
Antonio Quartulli

..each of us alone is worth nothing..
Ernesto "Che" Guevara
