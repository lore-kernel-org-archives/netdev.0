From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Sun, 01 Jul 2012 22:37:36 -0700 (PDT)
Message-ID: <20120701.223736.2073666097053189601.davem@davemloft.net>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	<20120701.202610.12425223200611171.davem@davemloft.net>
	<CAJFZqHxyR0PErHV8cqLLe6eqL0fCYS9gjPRc9zpthpevsU7wkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab2GBFhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 01:37:39 -0400
In-Reply-To: <CAJFZqHxyR0PErHV8cqLLe6eqL0fCYS9gjPRc9zpthpevsU7wkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing Li <roy.qing.li@gmail.com>
Date: Mon, 2 Jul 2012 13:23:09 +0800

> 2012/7/2 David Miller <davem@davemloft.net>:
>> From: roy.qing.li@gmail.com
>> Date: Mon,  2 Jul 2012 11:18:59 +0800
>>
>>> -     if (opt) {
>>> -             newnp->opt = ipv6_dup_options(newsk, opt);
>>> -             if (opt != np->opt)
>>> -                     sock_kfree_s(sk, opt, opt->tot_len);
>>
>> This is bogus, if we copy the options into a new copy in
>> ipv6_dup_options() we have to free the old one or else we
>> leak it.
> 
> Do you mean I should free newnp->opt firstly ?
> 
> If I understand it right, I think we do not need to free it. the
> process is below:
> 
> newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
> ..
> newnp = inet6_sk(newsk);
> ..
> memcpy(newnp, np, sizeof(struct ipv6_pinfo));
> ..
> newnp->opt         = NULL;
> 
> So newnp->opt is not a effective memory.

ipv6_dup_options() allocates new memory for the options and this call
statement assigns that new pointer to np->opt.

If you do not free the old (before ipv6_dup_options()) np->opt memory
here, it is lost forever.
