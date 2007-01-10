From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 01:24:29 -0800 (PST)
Message-ID: <20070110.012429.63126018.davem@davemloft.net>
References: <20070110072251.GA27030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932760AbXAJJYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 04:24:31 -0500
To: herbert.xu@redhat.com
In-Reply-To: <20070110072251.GA27030@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert.xu@redhat.com>
Date: Wed, 10 Jan 2007 18:22:51 +1100

> This patch also happens to fix a nasty bug where if an expiring
> flow entry that's not at the head happens to trigger a security
> denial, all entries before it are removed from the cache and
> leaked.

Nasty, this is because "fle != NULL" can occur in the
'nocache' path for two reasons.  New entry, or the case
that's buggy here, existing entry with out-of-date generation
ID.

Thanks Herbert, I'll look this over some more and apply it some
time tomorrow.

