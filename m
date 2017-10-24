From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] tcp/dccp: fix other lockdep splats accessing
 ireq_opt
Date: Tue, 24 Oct 2017 08:18:33 -0700
Message-ID: <1508858313.30291.110.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171023095634.lednbqrxtbuooqcx@inn>
         <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171024.185616.1718355795918406578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:44002 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdJXPSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 11:18:35 -0400
Received: by mail-pg0-f50.google.com with SMTP id s75so14778891pgs.0
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 08:18:35 -0700 (PDT)
In-Reply-To: <20171024.185616.1718355795918406578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-24 at 18:56 +0900, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 23 Oct 2017 16:15:08 -0700
> 
> > +static inline struct ip_options_rcu *ireq_opt_deref(const struct inet_request_sock *ireq)
> > +{
> > +	return rcu_dereference_check(ireq->ireq_opt,
> > +				     refcount_read(&ireq.req->rsk_refcnt) > 0);
>                                                     ^^^^^^^^^
> 
> Eric, _please_ build test your changes properly.

Ah, you mean the compiler is not fixing this small error for us ? :)

Sorry :/
