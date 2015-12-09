From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Remove unnecessary wmb for future_tbl
Date: Wed, 9 Dec 2015 03:52:12 +0100
Message-ID: <20151209025212.GB20213@pox.localdomain>
References: <20151208090904.GA17605@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34309 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbbLICwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:52:15 -0500
Received: by wmvv187 with SMTP id v187so240542176wmv.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 18:52:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151208090904.GA17605@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/15 at 05:09pm, Herbert Xu wrote:
> The patch 9497df88ab5567daa001829051c5f87161a81ff0 ("rhashtable:
> Fix reader/rehash race") added a pair of barriers.  In fact the
> wmb is superfluous because every subsequent write to the old or
> new hash table uses rcu_assign_pointer, which itself carriers a
> full barrier prior to the assignment.
> 
> Therefore we may remove the explicit wmb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

The RELEASE which is now in place afterwards act as a wmb as well,
we are well protected ;-)

Acked-by: Thomas Graf <tgraf@suug.ch>
