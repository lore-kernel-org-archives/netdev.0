From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Mon, 31 Jul 2006 14:15:59 -0700 (PDT)
Message-ID: <20060731.141559.95507027.davem@davemloft.net>
References: <44CDDDF7.70004@trash.net>
	<20060731113050.GA25972@gondor.apana.org.au>
	<44CE4DCA.8000609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9608
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751341AbWGaVQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 17:16:44 -0400
To: kaber@trash.net
In-Reply-To: <44CE4DCA.8000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Jul 2006 20:36:58 +0200

> I'm going to do some more testing now ..

Thanks for all of this work Patrick.

I noticed a subtle semantic change for nf_queue().  Previously, if we
can't grab the module reference for the matching entry, we'd not free
the skb, return 0, and the caller tries to iterate to the next hook.

That behavior is preserved for singleton frames, but that's not what
happens for GSO frames.  Instead, the GSO frame is split up and we
always return "1" even if some of the subsegments cause __nf_queue()
to return 0 due to the case described in the previous paragraph.

It is, however, mindful to free up the kfree_skb so it doesn't cause a
leak or anything like that.

Does this matter?

