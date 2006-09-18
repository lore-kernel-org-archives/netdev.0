From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Fix wildcard as tunnel source
Date: Mon, 18 Sep 2006 00:19:04 -0700 (PDT)
Message-ID: <20060918.001904.105429466.davem@davemloft.net>
References: <44F99954.1040606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6079
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965525AbWIRHTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:19:16 -0400
To: kaber@trash.net
In-Reply-To: <44F99954.1040606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 02 Sep 2006 16:46:44 +0200

> [XFRM]: Fix wildcard as tunnel source
> 
> Hashing SAs by source address breaks templates with wildcards as tunnel
> source. Remove saddr from the hash key.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Unfortunately, this break scalability of the xfrm state layer when the
source is equally as varying as the destination.  In such setups you
have an enormous number of entries with destination being the local
system and only the source address changing.

BTW, how can the source be specified as wildcard?  There is no prefix
component, it is simply an xfrm_address_t.  And there are several
macros which check for x->props.saddr equality directly with no
special prefixing or wildcard logic.

I really don't want to remove this as it's fairly critical performance
wise for the scalability problems all my changes were meant to address.
I hope I really don't have to do something like what was needed for
the policy layer, having a linked list and a hash table to handle the
two cases.
