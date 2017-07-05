From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [RFC] tls: length check correct in do_tls_getsockopt_tx()?
Date: Wed, 5 Jul 2017 13:07:40 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1707051306320.3050@hadrien>
References: <a0dac911-6401-12cb-611c-5a1723d943c1@gmail.com> <20170705101748.abfquxq73ey6lhme@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net, davejwatson@fb.com
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:37058
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752516AbdGELHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 07:07:44 -0400
In-Reply-To: <20170705101748.abfquxq73ey6lhme@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 5 Jul 2017, Dan Carpenter wrote:

> On Wed, Jul 05, 2017 at 03:10:53AM -0400, Matthias Rosenfelder wrote:
> > Hi,
> >
> > In do_tls_getsockopt_tx():
> >
> > if (len == sizeof(crypto_info)) {
> >
> > should be
> >
> > if (len == sizeof(*crypto_info)) {
> >
> > as crypto_info is of pointer type. Or am I missing something?
>
> No, you're right.  It should be "sizeof(*crypto_info)".
>
> It's hard for Smatch to catch these sorts of bugs because Sparse
> sometimes just gives Smatch a number literal instead of a sizeof()
> expression.  I think Coccinelle can catch these kinds of bugs?

Currently, I think the Coccinelle rules are only looking for things like x
= f(...,sizeof(x),...)

julia
