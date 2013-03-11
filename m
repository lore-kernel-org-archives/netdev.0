From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Mon, 11 Mar 2013 07:14:57 +0100
Message-ID: <1362982497.4051.37.camel@edumazet-glaptop>
References: <1362540509.15793.158.camel@edumazet-glaptop>
	 <20130305.233744.498353801662910535.davem@davemloft.net>
	 <1362553398.15793.168.camel@edumazet-glaptop>
	 <20130306.145947.1445904594058156164.davem@davemloft.net>
	 <1362606777.15793.198.camel@edumazet-glaptop>
	 <20130310083800.GC10448@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eilong@broadcom.com, jhs@mojatatu.com,
	Tom Herbert <therbert@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:34030 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab3CKGPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 02:15:03 -0400
Received: by mail-ea0-f181.google.com with SMTP id z10so994943ead.40
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 23:15:01 -0700 (PDT)
In-Reply-To: <20130310083800.GC10448@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 16:38 +0800, Herbert Xu wrote:
> On Wed, Mar 06, 2013 at 01:52:57PM -0800, Eric Dumazet wrote:
> >
> > - BQL (incurring more TX completion rounds and possibility to
> > block/unblock a qdisc)
> > - ticket spinlocks, and even with the guard of qdisc busylock
> > 
> > -> we can have a starvation problem.
> 
> This only happens in cases where we aren't using multiqueue or
> we're using it incorrectly, resulting in TX work from being split
> over CPUs.
> 

Or using qdisc like HTB ;)

> In that case it's not clear that it is starvation if we keep the
> TX processing on one CPU.

Thats not always the case. TX path has interesting features like XPS ...

We probably could add instrumentation and keep track of the maximum time
we are spending in this dark area.
