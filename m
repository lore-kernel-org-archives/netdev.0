From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Sun, 4 Jan 2009 18:43:39 +0100
Message-ID: <20090104174339.GX496@one.firstfloor.org>
References: <20090104151819.GA6590@basil.nowhere.org> <1231085150.3296.3.camel@johannes> <20090104162826.GT496@one.firstfloor.org> <1231087288.3296.15.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1231087288.3296.15.camel@johannes>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 04, 2009 at 05:41:28PM +0100, Johannes Berg wrote:
> On Sun, 2009-01-04 at 17:28 +0100, Andi Kleen wrote:
> > > Thanks, but I'll need to look at this in more detail, we need to make
> > > sure that we orphan the skb before 
> > 
> > What do you mean with orphaning the skb? 
> 
> Well, touching truesize is absolutely not allowed while the skb is
> charged to a socket. This is what causes the truesize warning. The thing

The cause of the warnings was because the skb changed, but
truesize didn't.

> we need to do is figure out is why the skb has a wrong truesize.

Because it was expanded without truesize being adjusted (see my
original mail) 

-Andi
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
