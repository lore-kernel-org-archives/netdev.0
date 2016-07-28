From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Thu, 28 Jul 2016 02:22:53 +0100
Message-ID: <20160728012253.GT2356@ZenIV.linux.org.uk>
References: <201607271032.u6RAWPcS008174@sdf.org>
 <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
 <87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
 <20160727.164543.1466564919313003461.davem@davemloft.net>
 <20160728003102.GS2356@ZenIV.linux.org.uk>
 <8b3126f66186015956e0f8090fb70532@triadic.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, rlwinm-WF+c3Tt1nJM@public.gmane.org,
	chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
To: alexmcwhirter-O8/uFoRGvHWcqzYg7KEe8g@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8b3126f66186015956e0f8090fb70532-O8/uFoRGvHWcqzYg7KEe8g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 08:26:48PM -0400, alexmcwhirter-O8/uFoRGvHWcqzYg7KEe8g@public.gmane.org wrote:

> I'm going to go ahead and say this is where my issue and the op's issue
> begin to branch apart from one another. He's seeing this on all incoming
> data, whereas i am only seeing it on ssl data and not on sun4v.
> 
> At this point i would say data from my issue is only going to cloud this
> issue as they seem to be two completely different issues revolving around
> the same commit. If i come across any relevant data for x86_64 ill be sure
> to post it if this isn't resolved by then, but for now i'm going to refrain
> from submitting anything sparc related.

Which just might mean that we have *three* issues here -
	(1) buggered __copy_to_user_inatomic() (and friends) on some sparcs
	(2) your ssl-only corruption
	(3) Alan's x86_64 corruption on plain TCP read - no ssl *or* sparc
anywhere, and no multi-segment recvmsg().  Which would strongly argue in
favour of some kind of copy_page_to_iter() breakage triggered when handling
a fragmented skb, as in (1).  Except that I don't see anything similar in
x86_64 uaccess primitives...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
