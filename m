From: Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH net-next v5 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Fri, 1 Sep 2017 02:21:18 +0200
Message-ID: <20170901002118.sprwhuybmk4spy34@ycc.fr>
References: <20170831165939.5121-1-colona@arista.com>
 <20170831165939.5121-3-colona@arista.com>
 <20170831232633.GA678@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36949 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdIAAVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 20:21:20 -0400
Received: by mail-wm0-f41.google.com with SMTP id u26so6623130wma.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 17:21:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170831232633.GA678@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 01:26:33AM +0200, Sabrina Dubroca wrote:
> 2017-08-31, 09:59:39 -0700, Ivan Delalande wrote:
> > diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> > index a748c74aa8b7..abbf0edcf6c2 100644
> > --- a/net/ipv4/tcp_diag.c
> > +++ b/net/ipv4/tcp_diag.c
> [...]
> > +static int tcp_diag_get_aux(struct sock *sk, bool net_admin,
> > +			    struct sk_buff *skb)
> > +{
> > +#ifdef CONFIG_TCP_MD5SIG
> > +	if (net_admin) {
> 
> In tcp_diag_get_aux_size() you put a check for sk_fullsock. I don't
> see anything preventing you from reaching this with a !fullsock?

Currently handler->idiag_get_aux is only called from inet_sk_diag_fill
which has a `BUG_ON(!sk_fullsock(sk));`, but I could add another
explicit check in that function if you think it's more consistent.

Actually, I wasn't sure when adding this idiag_get_aux in v2 if it
should be called from inet_twsk_diag_fill, inet_req_diag_fill and
inet_csk_diag_fill, or just the last one. I chose that simpler approach
for now to avoid duplicating these state checks in the idiag_get_aux
defined by protocols and because we didn't need for INET_DIAG_MD5SIG,
but it shouldn't be too hard to change. Do you think this could be
useful for other protocols or attributes?

Thank you,
-- 
Ivan Delalande
Arista Networks
