From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 22:16:59 +0200
Message-ID: <20080528201659.GA2696@ami.dom.local>
References: <200805270325.24323.opurdila@ixiacom.com> <200805282102.02805.opurdila@ixiacom.com> <483DBA0D.8090402@gmail.com> <200805282309.13628.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:54477 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbYE1URO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 16:17:14 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1408340nfc.21
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 13:17:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200805282309.13628.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 11:09:13PM +0300, Octavian Purdila wrote:
> On Wednesday 28 May 2008, Jarek Poplawski wrote:
> 
> > >> We queue data under the lock and clone appropriate skb (and then grab it
> > >> multiple times), so even it will be dropped, its data will not freed,
> > >> and thus we will be able to read it. Or you are talking about different
> > >> skbs?
> > >
> > > You are right, I forgot about the clone.
> >
> > Probably I miss something, but how does it help when tcp_collapse()
> > uses __kfree_skb()?
> >
> 
> __kfree_skb() -> skb_release_all() -> skb_release_data():
> 
> static void skb_release_data(struct sk_buff *skb)
> {
>         if (!skb->cloned ||
> <snip>
>                 kfree(skb->head);
> 
> Since we clone the skb in skb_splice_bits() the skb's data will only be freed 
> when the last clone is deleted.

Right!

Thanks for explanation,
Jarek P.
