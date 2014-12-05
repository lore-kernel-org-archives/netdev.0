From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 1/2] net: sched: cls_basic: fix error path in
 basic_change()
Date: Fri, 05 Dec 2014 08:03:51 -0800
Message-ID: <1417795431.15618.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
	 <5481CF4C.2060607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:48463 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaLEQDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 11:03:54 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so943821iec.36
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 08:03:53 -0800 (PST)
In-Reply-To: <5481CF4C.2060607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 07:29 -0800, John Fastabend wrote:
> On 12/05/2014 06:50 AM, Jiri Pirko wrote:
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > ---
> >   net/sched/cls_basic.c | 5 ++---
> >   1 file changed, 2 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
> > index 7cf0a62..5aed341 100644
> > --- a/net/sched/cls_basic.c
> > +++ b/net/sched/cls_basic.c
> > @@ -178,10 +178,9 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
> >   			return -EINVAL;
> >   	}
> >
> > -	err = -ENOBUFS;
> >   	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
> > -	if (fnew == NULL)
> > -		goto errout;
> > +	if (!fnew)
> > +		return -ENOBUFS;
> >
> >   	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
> >   	err = -EINVAL;
> >
> 
> Nice catch, thanks!
> 
> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>

Sorry, but this looks a cosmetic change, right ?

If it is a fix, we'd like a 'Fixes: ...' tag.
