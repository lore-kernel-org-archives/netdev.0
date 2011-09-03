From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: Initialize entire flowi struct
Date: Sat, 3 Sep 2011 10:27:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
References: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu> <alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg> <4E5F89E3.5060903@ll.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51715 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202Ab1ICH1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Sep 2011 03:27:46 -0400
In-Reply-To: <4E5F89E3.5060903@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 1 Sep 2011, Ward, David - 0663 - MITLL wrote:

> > 	Not sure if adding size as parameter to flow_hash_code
> > is better approach. May be flow_cache_lookup needs to
> > determine size from family that can be used for flow_hash_code,
> > flow_key_compare and the memcpy(&fle->key, key, sizeof(*key))
> > after fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC).
> 
> Makes sense to me.  However should we just replace flow_key_compare with
> memcmp then, since the assumptions about constant size and alignment will no
> longer apply?  Or should there be a separate flow_key_compare function for
> each family, and have all of the flowi* structures become
> __attribute__((__aligned__(BITS_PER_LONG/8))) ?

	I don't know this code well but I guess memcmp is
not preferred. IMHO, as the callers provide per-family
structures and we do not want to change that, these
structures must be aligned to long type as required by
flow_compare_t and jhash2 (at least u32) usage. The second
option is to use memcmp and jhash instead of jhash2 to
avoid such alignment but I guess other developers will
oppose it. More opinions are needed here.

Regards

--
Julian Anastasov <ja@ssi.bg>
