From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 20:38:48 -0700
Message-ID: <1346211528.3571.26.camel@edumazet-glaptop>
References: <CAPgLHd9m2VbFFXt5Q3MMrK6BPXvMrT-ptq+RfgBToXOpxAKOOw@mail.gmail.com>
	 <1346163154.3571.6.camel@edumazet-glaptop>
	 <20120828161719.6faca38c@obelix.rh>
	 <1346184598.3571.16.camel@edumazet-glaptop>
	 <20120828173929.7b371079@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58523 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab2H2Diu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 23:38:50 -0400
Received: by pbbrr13 with SMTP id rr13so375802pbb.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 20:38:50 -0700 (PDT)
In-Reply-To: <20120828173929.7b371079@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-28 at 17:39 -0300, Flavio Leitner wrote:

> Ok, and what if kfree_skb() becomes a macro that first checks
> if the skb is NULL and if not, call the _kfree_skb() to
> continue as before?
> 
> #define kfree_skb(skb)		\
>         if (skb)		\
> 		_kfree_skb(skb)	\

Then its adding a conditional test on each call site and increase
kernel code size.

So if you plan submitting such patch, please keep the whole thing out of
line.
