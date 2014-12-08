From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] net: sched: cls_basic: fix error path in
 basic_change()
Date: Mon, 8 Dec 2014 08:27:56 +0100
Message-ID: <20141208072756.GA1863@nanopsycho.orion>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
 <5481CF4C.2060607@gmail.com>
 <1417795431.15618.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:54632 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbaLHH16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 02:27:58 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so5410832wgh.6
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 23:27:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417795431.15618.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 05, 2014 at 05:03:51PM CET, eric.dumazet@gmail.com wrote:
>On Fri, 2014-12-05 at 07:29 -0800, John Fastabend wrote:
>> On 12/05/2014 06:50 AM, Jiri Pirko wrote:
>> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> > ---
>> >   net/sched/cls_basic.c | 5 ++---
>> >   1 file changed, 2 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
>> > index 7cf0a62..5aed341 100644
>> > --- a/net/sched/cls_basic.c
>> > +++ b/net/sched/cls_basic.c
>> > @@ -178,10 +178,9 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
>> >   			return -EINVAL;
>> >   	}
>> >
>> > -	err = -ENOBUFS;
>> >   	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
>> > -	if (fnew == NULL)
>> > -		goto errout;
>> > +	if (!fnew)
>> > +		return -ENOBUFS;
>> >
>> >   	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
>> >   	err = -EINVAL;
>> >
>> 
>> Nice catch, thanks!
>> 
>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>
>Sorry, but this looks a cosmetic change, right ?
>
>If it is a fix, we'd like a 'Fixes: ...' tag.

Yep, cosmetic, no need to go to kfree in case kzalloc fails.
