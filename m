From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Fri, 10 Nov 2006 09:54:58 -0800
Message-ID: <OFF1265537.E903A772-ON88257222.006212AE-88257222.00626AB7@us.ibm.com>
References: <4554A7CD.6040907@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:989 "EHLO e31.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1161909AbWKJRzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 12:55:07 -0500
In-Reply-To: <4554A7CD.6040907@hp.com>
To: Brian Haley <brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, I saw this discussion a little late...

The Internet checksum is defined as a 1's-complement sum, so if  the
alternate 0 does not have a special meaning in a protocol, then by
1's-complement arithmetic, 0 == ~0.
        So, it looks to me without the remapping that a valid checksum
may also fail, if it is simply computed in a different way (or on a 
different
architecture) such that one gets 0 and one gets ~0 as un-modified answers.
        Since we're checking for equality on 2's-complement machines,
I think the easiest thing is to still re-map it. Otherwise, instead of 
testing
for 0, we have to test for both 0 and ~0 in the validity checks, right?

        Disclaimer: I've just glanced through the discussion, so maybe
I've misunderstood the point or effect of the patch...

                                                +-DLS

