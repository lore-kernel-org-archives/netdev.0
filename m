From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Mon, 18 Aug 2008 01:21:40 +0300
Message-ID: <200808180121.40998.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808172236.17857.denys@visp.net.lb> <20080817214752.GA2546@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:36522 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbYHQWWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:22:51 -0400
In-Reply-To: <20080817214752.GA2546@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Short testing - TBF is working fine. No warnings, no oops, nothing yet. 
Before - intensive changes was causing oops easily. I will test for 1 day 
more with TBF.

P.S. New shaper (based on flow classifier + HTB classes, instead of prio+tbf) 
crashing very fast on loaded server. Probably it is another bug.
Here is message:
http://www.nuclearcat.com/files/crash-newshaper.txt

On Monday 18 August 2008, Jarek Poplawski wrote:
> On Sun, Aug 17, 2008 at 10:36:17PM +0300, Denys Fedoryshchenko wrote:
> > I am lost in patches :-)
> > When you will be back, let me know if order and set of patches is
> > correct. Here is what i am using:
> >
> > http://www.nuclearcat.com/patches/00-prevfixes1.patch
> > http://www.nuclearcat.com/patches/00-prevfixes2.patch
> > http://www.nuclearcat.com/patches/01-take3.patch
> > http://www.nuclearcat.com/patches/02-fix1.patch
> > http://www.nuclearcat.com/patches/03-fix_patch_2.patch
> >
> > And thanks for your help!
> > I cannot take risk and put to wide production, since it is crashing
> > sometimes, but i guess in few days we can make it ready for production.
>
> OK, so please try to test with all these patches above plus one new
> patch below.
>
> Thanks,
> Jarek P.
>
> (04-fix_patch_3.patch)
> ---
>
>  net/sched/sch_api.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index c25465e..c8dc72e 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -638,9 +638,9 @@ static void notify_and_destroy(struct sk_buff *skb,
> struct nlmsghdr *n, u32 clid qdisc_notify(skb, n, clid, old, new);
>
>  	if (old) {
> -		spin_lock_bh(&old->q.lock);
> +		sch_tree_lock(old);
>  		qdisc_destroy(old);
> -		spin_unlock_bh(&old->q.lock);
> +		sch_tree_unlock(old);
>  	}
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


