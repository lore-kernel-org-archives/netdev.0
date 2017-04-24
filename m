From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 11:14:56 +0200
Message-ID: <20170424091455.GA25218@vergenet.net>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <a0d70dc5-b0cb-c54e-7d98-93099b68c247@mojatatu.com>
 <20170420142453.GF1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33963 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1167748AbdDXJPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 05:15:05 -0400
Received: by mail-wr0-f182.google.com with SMTP id z109so87860385wrb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 02:15:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170420142453.GF1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 04:24:53PM +0200, Jiri Pirko wrote:
> Thu, Apr 20, 2017 at 04:18:50PM CEST, jhs@mojatatu.com wrote:
> >On 17-04-20 09:59 AM, Jiri Pirko wrote:
> >> Thu, Apr 20, 2017 at 03:06:21PM CEST, jhs@mojatatu.com wrote:
> >> > From: Jamal Hadi Salim <jhs@mojatatu.com>

...

> >> > +	if (tcaa[TCAA_ACT_FLAGS])
> >> > +		act_flags = nla_get_u32(tcaa[TCAA_ACT_FLAGS]);
> >> 
> >> I still believe this is wrong. Should be a separate attr per flag.
> >> For user experience breakage reasons:
> >> 2 kernels should not behave differently on the exact same value passed
> >> from userspace:
> >> User passes 0x2. Now the kernel will ignore the set bit, the next kernel
> >> will recognize it as a valid flag and do something.
> >> Please let the discussion reach a consensus before pushing this again.
> >> 
> >> 
> >
> >Jiri - I dont agree. There is no such breakage. Refer to my previous
> >email. Lets just move on.
> 
> Anyone else has opinion on this?

At the risk of jumping into a hornets nest, yes, I have an opinion:

* A agree with Jiri that a separate attribute per flag seems to be
  the cleanest option, however;
* I think it would be reasonable from a UABI PoV to permit currently unused
  bits of TCAA_ACT_FLAGS to be re-uses so long as the kernel checks that
  they are zero until they are designated to have some use. I believe this
  implies that the default value for any future uses of these bits would be
  zero.

Jamal, I am confused about why are you so concerned about the space
consumed by this attribute, it's per-message, right? Is it the bigger
picture you are worried about - a similar per-entry flag at some point in
the future?
