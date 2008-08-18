From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Kill qdisc rcu freeing...
Date: Mon, 18 Aug 2008 12:07:25 +0000
Message-ID: <20080818120725.GB7393@ff.dom.local>
References: <20080817.223435.193704624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:41068 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156AbYHRMHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 08:07:33 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1123877nfc.21
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 05:07:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080817.223435.193704624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 10:34:35PM -0700, David Miller wrote:
> 
> Ok, I flipped the switch.  I've checked in the following to
> net-2.6 and it seems to pass a bunch of smoke tests I just
> did (flood pings while adding and deleting various qdisc
> setups, etc.)
> 
> Jarek, I think we can possibly now revert that locking change
> you had to make because destroy was outside of RTNL?

Yes, I think there are these two patches only to revert:

----------
commit d4766692e72422f3b0f0e9ac6773d92baad07d51
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Wed Aug 13 15:20:24 2008 -0700

    pkt_sched: Protect gen estimators under est_lock.

----------

commit 1cfa26661a85549063e369e2b40275eeaa7b923c
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Mon Aug 11 18:11:06 2008 -0700

    pkt_sched: Add BH protection for qdisc_stab_lock.

----------

I guess, I don't need to send any patches, but let me know if I'm
wrong.

Thanks,
Jarek P.

> 
> pkt_sched: No longer destroy qdiscs from RCU.
> 
> We can now kill them synchronously with all of the
> previous dev_deactivate() cures.
> 
> This makes netdev destruction and shutdown saner as
> the qdiscs hold references to the device.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
...
