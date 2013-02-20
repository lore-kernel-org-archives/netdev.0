From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [Patch] net: fix a wrong assignment in skb_split()
Date: Wed, 20 Feb 2013 13:32:21 -0800
Message-ID: <20130220133221.00001491@unknown>
References: <1361350290-28581-1-git-send-email-amwang@redhat.com>
	<CALnjE+rwqV_APx-epsaiF6KjvjSmXU=iORwVyNov8Zvk9we0HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27292 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab3BTVc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 16:32:26 -0500
In-Reply-To: <CALnjE+rwqV_APx-epsaiF6KjvjSmXU=iORwVyNov8Zvk9we0HQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2013 10:42:18 -0800
Pravin Shelar <pshelar@nicira.com> wrote:

> On Wed, Feb 20, 2013 at 12:51 AM, Cong Wang <amwang@redhat.com> wrote:
> > commit c9af6db4c11ccc6c3e7f1 (net: Fix possible wrong checksum
> > generation) has a suspicous piece:
> >
> >         -       skb_shinfo(skb1)->gso_type =
> > skb_shinfo(skb)->gso_type; -
> >         +       skb_shinfo(skb)->tx_flags =
> > skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
> >
> > skb1 is the new skb, therefore should be on the left side of the
> > assignment. This patch fixes it.

It looks to me like skb1 is on the right side of the assignment?

- Greg

> >
> > Cc: Pravin B Shelar <pshelar@nicira.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> >
> Looks good.
> 
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> 
> > ---
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 2a3ca33..33245ef 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -2326,7 +2326,7 @@ void skb_split(struct sk_buff *skb, struct
> > sk_buff *skb1, const u32 len) {
> >         int pos = skb_headlen(skb);
> >
> > -       skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags &
> > SKBTX_SHARED_FRAG;
> > +       skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags &
> > SKBTX_SHARED_FRAG; if (len < pos)  /* Split line is inside header.
> > */ skb_split_inside_header(skb, skb1, len, pos);
> >         else            /* Second chunk has no header, nothing to
> > copy. */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
