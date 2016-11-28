From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [PATCH net] net/sched: act_pedit: limit negative offset
Date: Mon, 28 Nov 2016 09:51:47 +0200
Message-ID: <20161128075147.GA27667@office.localdomain>
References: <20161127155815.10359-1-amir@vadai.me>
 <CAM_iQpX1at1w=3OfRFchn3STTDJGXj640tGetxXToR=EyddpEw@mail.gmail.com>
 <20161128.004936.2064564176474656911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        ogerlitz@mellanox.com, hadarh@mellanox.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:36350 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754022AbcK1Hvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 02:51:51 -0500
Received: by mail-wj0-f193.google.com with SMTP id jb2so12899497wjb.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 23:51:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161128.004936.2064564176474656911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 12:49:36AM -0500, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Sun, 27 Nov 2016 21:39:33 -0800
> 
> > On Sun, Nov 27, 2016 at 7:58 AM, Amir Vadai <amir@vadai.me> wrote:
> >> Should not allow setting a negative offset that goes below the skb head.
> > ...
> >> diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
> >> index b54d56d4959b..e79e8a88f2d2 100644
> >> --- a/net/sched/act_pedit.c
> >> +++ b/net/sched/act_pedit.c
> >> @@ -154,8 +154,11 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
> >>                         }
> >>
> >>                         ptr = skb_header_pointer(skb, off + offset, 4, &_data);
> >> -                       if (!ptr)
> >> +                       if ((unsigned char *)ptr < skb->head) {
> > 
> > 
> > ptr returned could be &_data, which is on stack, so why this comparison
> > makes sense for this case?
> 
> Indeed, this will definitely do the wrong thing when the on-stack area
> passed back to ptr.
yes - my bad. will correct it and send v1
