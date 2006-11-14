From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Mon, 13 Nov 2006 16:50:58 -0800 (PST)
Message-ID: <20061113.165058.15265737.davem@davemloft.net>
References: <4554A7CD.6040907@hp.com>
	<OFF1265537.E903A772-ON88257222.006212AE-88257222.00626AB7@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35979
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933271AbWKNAuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:50:50 -0500
To: dlstevens@us.ibm.com
In-Reply-To: <OFF1265537.E903A772-ON88257222.006212AE-88257222.00626AB7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 10 Nov 2006 09:54:58 -0800

> The Internet checksum is defined as a 1's-complement sum, so if  the
> alternate 0 does not have a special meaning in a protocol, then by
> 1's-complement arithmetic, 0 == ~0.
>         So, it looks to me without the remapping that a valid checksum
> may also fail, if it is simply computed in a different way (or on a 
> different
> architecture) such that one gets 0 and one gets ~0 as un-modified answers.
>         Since we're checking for equality on 2's-complement machines,
> I think the easiest thing is to still re-map it. Otherwise, instead of 
> testing
> for 0, we have to test for both 0 and ~0 in the validity checks, right?

Puzzling :-)  Then why is the transformation only performed for
UDP in the ipv4 stack?  It seems by your logic TCP would need
to either do the "if (sum==0) sum=~0;"  thing or it would need
to accept both "0" and "~0" in the checksum checking path.
