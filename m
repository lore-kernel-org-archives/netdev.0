From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Thu, 14 Jun 2007 21:21:11 +1000
Message-ID: <20070614112111.GB25207@gondor.apana.org.au>
References: <1181724049.10679.31.camel@localhost.localdomain> <D5C1322C3E673F459512FB59E0DDC3290306A777@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kumarkr@linux.vnet.ibm.com, davem@davemloft.net, jamal@cyberus.ca,
	tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2467 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751379AbXFNLVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 07:21:34 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290306A777@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 10:51:00AM -0700, Waskiewicz Jr, Peter P wrote:
> 
> I somewhat disagree here.  The underlying driver can conceivably stop
> the device queue even if the stack holds the queue lock during an
> interrupt to clean Tx descriptors, and it finds it's out of them or
> needs to grab the device for whatever reason.  Granted this is a corner
> case, and the net effect would be a simple requeue of the skb, but
> checking the status of the queue at the last possible moment before
> entering the driver could alleviate the requeue in the time between
> ->dequeue() from the qdisc, and hard_start_xmit() if an event like I
> mentioned happened.

IMHO this scenario occurs so infrequently that the check isn't worth it
especially since the driver has to be able to deal with us calling it
after netif_stop_queue() anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
