From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in tcp_ipv6.c
Date: Mon, 2 Jul 2012 13:23:09 +0800
Message-ID: <CAJFZqHxyR0PErHV8cqLLe6eqL0fCYS9gjPRc9zpthpevsU7wkA@mail.gmail.com>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	<20120701.202610.12425223200611171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:51388 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab2GBFXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 01:23:10 -0400
Received: by obbuo13 with SMTP id uo13so7685867obb.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 22:23:09 -0700 (PDT)
In-Reply-To: <20120701.202610.12425223200611171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/7/2 David Miller <davem@davemloft.net>:
> From: roy.qing.li@gmail.com
> Date: Mon,  2 Jul 2012 11:18:59 +0800
>
>> -     if (opt) {
>> -             newnp->opt = ipv6_dup_options(newsk, opt);
>> -             if (opt != np->opt)
>> -                     sock_kfree_s(sk, opt, opt->tot_len);
>
> This is bogus, if we copy the options into a new copy in
> ipv6_dup_options() we have to free the old one or else we
> leak it.

Do you mean I should free newnp->opt firstly ?

If I understand it right, I think we do not need to free it. the
process is below:

newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
..
newnp = inet6_sk(newsk);
..
memcpy(newnp, np, sizeof(struct ipv6_pinfo));
..
newnp->opt         = NULL;

So newnp->opt is not a effective memory.


Thanks.
-Roy
