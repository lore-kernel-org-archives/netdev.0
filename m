From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 13:07:52 +0200
Message-ID: <20170426110750.GB28251@vergenet.net>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:35509 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999184AbdDZLH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 07:07:56 -0400
Received: by mail-wr0-f176.google.com with SMTP id z52so82205276wrc.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 04:07:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426061904.GB1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 08:19:04AM +0200, Jiri Pirko wrote:
> Tue, Apr 25, 2017 at 10:29:40PM CEST, jhs@mojatatu.com wrote:

...

> >So lets in first kernel I have support for bit 0.
> >My validation check is to make sure only bit 0 is set.
> >The valid_flags currently then only constitutes bit 0.
> >i.e
> >If you set bit 2 or 3, the function above will reject and i return
> >the error to the user.
> >
> >That is expected behavior correct?
> >
> >3 months down the road:
> >I add two flags - bit 1 and 2.
> >So now my valid_flags changes to bits 1, 2 and 0.
> >
> >The function above will now return true for bits 0-2 but
> >will reject if you set bit 3.
> >
> >That is expected behavior, correct?
> 
> The same app compiled against new kernel with bits (0, 1, 2) will run with
> this kernel good. But if you run it with older kernel, the kernel (0)
> would refuse. Is that ok?

Conversely, if an app is compiled against a new kernel and uses ATTR0, ATTR1
and ATTR2 all will be well. But if you run it against the older kernel
ATTR1 and ATTR2 will be silently ignored. I believe that is how its always
been but is that ok?

> >On u32/16/8:
> >I am choosing u32 so it allows me to add more upto 32 bit flags.
> >Not all 32 are needed today but it is better insurance.
> >If I used u8 then the 24 of those 32 bits i dont use will be used
> >as pads in the TLV. So it doesnt make sense for me to use a u8/16.
> 
> Jamal, note that I never suggested having more flags in a single attr.
> Therefore I suggested u8 to carry a single flag.
> 
> You say that it has performance impact having 3 flag attrs in compare to
> one bit flag attr. Could you please provide some numbers?
> 
> I expect that you will not be able to show the difference. And if there
> is no difference in performance, your main argument goes away. And we
> can do this in a nice, clear, TLV fashion.
