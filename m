From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Thu, 14 Jun 2007 21:19:20 +1000
Message-ID: <20070614111920.GA25207@gondor.apana.org.au>
References: <1181724049.10679.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jamal@cyberus.ca,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2453 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751235AbXFNLUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 07:20:04 -0400
Content-Disposition: inline
In-Reply-To: <1181724049.10679.31.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 02:10:49PM +0530, Krishna Kumar wrote:
> 
> - BUG_ON((int) q->q.qlen < 0) was a relic from old times when -1
>   meant more packets are available, and __qdisc_run used to loop
>   when qdisc_restart() returned -1. During those days, it was
>   necessary to make sure that qlen is never less than zero, since
>   __qdisc_run would get into an infinite loop if no packets are on
>   the queue and this bug in qdisc was there (and worse - no more
>   skbs could ever get queue'd as we hold the queue lock too). With
>   Herbert's recent change to return values, this check is not
>   required.  Hopefully Herbert can validate this change. If at all
>   this is required, it should be added to skb_dequeue (in failure
>   case), and not to qdisc_qlen.

Yes I agree that this check is no longer critical.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
