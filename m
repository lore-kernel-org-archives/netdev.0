From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] net: convert BUG_TRAP to generic WARN_ON
Date: Sat, 26 Jul 2008 00:19:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807260003200.11441@wrl-59.cs.helsinki.fi>
References: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <E1KMPJS-0005Dh-00@gondolin.me.apana.org.au> <20080725.132105.175832134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44536 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbYGYVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 17:19:46 -0400
In-Reply-To: <20080725.132105.175832134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2008, David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 25 Jul 2008 23:34:34 +0800
> 
> > Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > >
> > > diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
> > > index a75807b..ee1bbf9 100644
> > > --- a/net/ipv4/ipcomp.c
> > > +++ b/net/ipv4/ipcomp.c
> > > @@ -293,7 +293,7 @@ static void ipcomp_free_tfms(struct crypto_comp **tfms)
> > >                        break;
> > >        }
> > > 
> > > -       BUG_TRAP(pos);
> > > +       WARN_ON(!pos);
> > 
> > Sorry I've just moved this to net/xfrm/xfrm_ipcomp.c.  BTW,
> > please also remove rtnetlink.h from ipcomp.c since that's only
> > included for this macro.
> 
> This is my fault, I didn't push before going to bed last night.
> Otherwise Ilpo would have seen this sooner.
> 
> I've just taken care of this.

Thanks! I thought Herbert patch was related but since I couldn't find it 
in your tree I assumed that you volunteer to fix it like you usually do 
with the other people too who are hit by a merge conflicts due to some 
very recent merges. Afterwards I realized that I could have just
included his patch locally but honestly it was after I made and sent
that one out... :-)

I anyway intend to drop as many linux/rtnetlink.h includes as possible in 
the modified files in a later series but since it requires more care than 
the plain conversion it takes some more time to validate, and extra 
includes won't hurt that much anyway.

-- 
 i.
