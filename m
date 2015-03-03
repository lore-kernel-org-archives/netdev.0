From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 03 Mar 2015 06:07:44 -0800
Message-ID: <1425391664.5130.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41004 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbbCCOHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:07:46 -0500
Received: by iecrd18 with SMTP id rd18so58221856iec.8
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:07:45 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 13:50 +0000, David Laight wrote:
> From: Florian Westphal
> > make build fail if structure no longer fits into ->cb storage.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Change since v1: use FIELD_SIZEOF
> > 
> >  checkpatch complains about >80 chars, but line break is ugly here.
> > 
> > diff --git a/net/bridge/br.c b/net/bridge/br.c
> > index fb57ab6..02c24cf 100644
> > --- a/net/bridge/br.c
> > +++ b/net/bridge/br.c
> > @@ -190,6 +190,8 @@ static int __init br_init(void)
> >  {
> >  	int err;
> > 
> > +	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> > +
> 
> What about using something based on:
> #define GET_CB(skb, type) ((type *)((skb)->cb + (sizeof (char[(sizeof (type) <= sizeof (skb->cb)) ? 1 : -1] - 1)))
> to access skb->sb?
> 
> Then all invalid uses are likely to be picked up.

We want a build error, not a runtime one.
