From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net: Fix vti use case with oif in dst lookups
Date: Wed, 16 Sep 2015 10:21:14 +0200
Message-ID: <20150916082114.GA7701@secunet.com>
References: <1442355050-9214-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41554 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbbIPIVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 04:21:18 -0400
Content-Disposition: inline
In-Reply-To: <1442355050-9214-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 03:10:50PM -0700, David Ahern wrote:
> Steffen reported that the recent change to add oif to dst lookups breaks
> the VTI use case. The problem is that with the oif set in the flow struct
> the comparison to the nh_oif is triggered. Fix by splitting the
> FLOWI_FLAG_VRFSRC into 2 flags -- one that triggers the vrf device cache
> bypass (FLOWI_FLAG_VRFSRC) and another telling the lookup to not compare
> nh oif (FLOWI_FLAG_SKIP_NH_OIF).
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

This works, thanks a lot for the quick fix!

> ---
> IPv6 does not show this problem for me. So no change is added for IPv6.
> If your mileage varies let me know and I'll take another look.

IPv6 works just fine as it is, so no change needed.

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
