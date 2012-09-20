From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] core: adjust checks for calling skb_copy_bits in skb_try_coalesce
Date: Thu, 20 Sep 2012 13:40:19 +0800
Message-ID: <CAJFZqHzTEwgJaKjvNLW3yYbMLUu0xm8tHwQ2e_TZJNdiTKOTFw@mail.gmail.com>
References: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
	<1348118417.31352.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:51434 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab2ITFkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:40:20 -0400
Received: by oago6 with SMTP id o6so1815020oag.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 22:40:20 -0700 (PDT)
In-Reply-To: <1348118417.31352.52.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>               unsigned int offset;
>
> This is not needed at all.
>
>

I think the below modification maybe needed,
if (len <= skb_tailroom(to) && !skb_shinfo(to)->nr_frags) {
..
}

First skb A is added to skb TO frags, since the len is larger
than skb_tailroot(TO), but second len of skb B is less than
skb_tailroot(To)  which will call skb_copy_bits.

Of cause, this kinds of cases maybe only exist on my mind.

-Roy
