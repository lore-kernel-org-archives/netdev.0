From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] core: adjust checks for calling skb_copy_bits
 in skb_try_coalesce
Date: Thu, 20 Sep 2012 07:53:58 +0200
Message-ID: <1348120438.31352.63.camel@edumazet-glaptop>
References: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
	 <1348118417.31352.52.camel@edumazet-glaptop>
	 <CAJFZqHzTEwgJaKjvNLW3yYbMLUu0xm8tHwQ2e_TZJNdiTKOTFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33627 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab2ITFyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:54:08 -0400
Received: by wibhi8 with SMTP id hi8so193759wib.1
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 22:54:07 -0700 (PDT)
In-Reply-To: <CAJFZqHzTEwgJaKjvNLW3yYbMLUu0xm8tHwQ2e_TZJNdiTKOTFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 13:40 +0800, RongQing Li wrote:
> >>               unsigned int offset;
> >
> > This is not needed at all.
> >
> >
> 
> I think the below modification maybe needed,
> if (len <= skb_tailroom(to) && !skb_shinfo(to)->nr_frags) {
> ..
> }
> 
> First skb A is added to skb TO frags, since the len is larger
> than skb_tailroot(TO), but second len of skb B is less than
> skb_tailroot(To)  which will call skb_copy_bits.
> 
> Of cause, this kinds of cases maybe only exist on my mind.
> 

Did you read skb_tailroom(to) definition by any chance ?

static inline int skb_tailroom(const struct sk_buff *skb)
{
        return skb_is_nonlinear(skb) ? 0 : skb->end - skb->tail;
}

Current code is fine, because if @to is linear, its ... linear.
