From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-11-26
Date: Fri, 02 Dec 2011 12:57:25 -0500 (EST)
Message-ID: <20111202.125725.896787381527077500.davem@davemloft.net>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
	<20111126.144122.775553783672941660.davem@davemloft.net>
	<20111202171216.GA4561@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20111202171216.GA4561-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Fri, 2 Dec 2011 18:12:16 +0100

> First of all I think you are referring to patch 08/10, in which I moved a
> skb_linearise() operation.
> 
> To be sure it is really needed, I backtracked the code flow and noted down any
> eventual psbk_may_pull() (or any other linearisation operation). The result is:
> 
> => in batman_skb_recv()
> 	- pskb_may_pull(2)
>   => in recv_tt_query()
>   	  - pskb_may_pull(sizeof(header))
> 	  - skb_linearise()
> 
> Actually it seems we haven't any useless linearisation.
> Would you mind explain us where you actually found the problem, please?
> 
> It might also be that I misunderstood your advice.

You only need to call pskb_may_pull() on the parts of the packet you want to
access directly to parse headers etc.

If you use that interface properly, you never need to linearize, ever.
