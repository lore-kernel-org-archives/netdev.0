From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 07:11:06 +0200
Message-ID: <200608080711.06788.ak@suse.de>
References: <44D75EF8.1070901@sw.ru> <20060807164842.GA3412@ms2.inr.ac.ru> <20060807.204214.68039839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44985 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750835AbWHHFLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 01:11:24 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.204214.68039839.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> So for now it is probably sufficient to just get rid of the
> HASH_HIGHMEM flag here.  Later we can try changing this multiplier
> of "16" to something like "8" or even "4".

The hash sizing code needs far more tweaks. iirc it can still allocate several GB 
hash tables on large memory systems (i've seen that once in the boot log
of a 2TB system).  Even on smaller systems it is usually too much.

IMHO there needs to be a maximum size (maybe related to the sum of 
caches of all CPUs in the system?)

Best would be to fix this for all large system hashes together.

-Andi
