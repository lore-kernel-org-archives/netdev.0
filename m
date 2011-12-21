From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Tue, 20 Dec 2011 21:50:32 -0800
Message-ID: <1324446632.21340.4.camel@joe2Laptop>
References: <4EF16AA3.2070303@linux.vnet.ibm.com>
	 <1324445033.20505.2.camel@joe2Laptop> <4EF170F5.5040900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49410 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750958Ab1LUFud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 00:50:33 -0500
In-Reply-To: <4EF170F5.5040900@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 13:39 +0800, Michael Wang wrote:
> On 12/21/2011 01:23 PM, Joe Perches wrote:
> > On Wed, 2011-12-21 at 13:12 +0800, Michael Wang wrote:
> >> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> >>
> >> If previous condition doesn't meet, the later check will be cancelled.
> >> So we don't need to do all the calculation.
[]
> > commit c0b8c32b1c96afc9b32b717927330025cc1c501e
> > Author: Stephen Hemminger <shemminger@vyatta.com>
> > Date:   Thu Apr 10 04:00:28 2008 -0700
> > 
> >     IPV4: use xor rather than multiple ands for route compare
> >     
> >     The comparison in ip_route_input is a hot path, by recoding the C
> >     "and" as bit operations, fewer conditional branches get generated
> >     so the code should be faster. Maybe someday Gcc will be smart
> >     enough to do this?
> This is what confused me, why "fewer conditional branches get generated"
> will make code faster?
> In this example, I think the best condition when daddr is different, we
> only need to go to one branch do compare then quit, won't this be faster?

	if (a && b)
		...
pseudo-codes to:
	if (!a)
		goto fail;
	if (!b)
		goto fail;
	...
fail:

Each of those conditional branches has a cost.
Combining tests of variables in the same cache lines
has relatively little cost compared to the conditional
branches.

That's the theory anyway.

If you have tests that demonstrate otherwise, please
provide them.

cheers, Joe
