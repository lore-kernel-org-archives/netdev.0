From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] ipv4 neigh: match add/del dev lookup
 behaviour to SIOCSARP/SIOCDARP
Date: Tue, 24 Feb 2015 16:03:23 -0500 (EST)
Message-ID: <20150224.160323.126491555542895936.davem@davemloft.net>
References: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@mojatatu.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbbBXVDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:03:25 -0500
In-Reply-To: <1424756572-29379-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Mon, 23 Feb 2015 21:42:52 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Today neigh adds and dels using the netlink RTM_NEWNEIGH/RTM_DELNEIGH
> messages require dst device to be specified. The equivalent ipv4 neigh
> entry add/del using SIOCSARP/SIOCDARP does not require a device. It finds
> the dst dev by doing a route lookup (ip_route_output).
> 
> This patch tries to match netlink ipv4 neigh add/del behaviour with
> SIOCSARP/SIOCDARP for the case where user does not specify a device.
> If user has not specified a dst device, it looks for the device via a
> route lookup. If the route lookup fails, the behaviour is unchanged,
> the user will get an -EINVAL as before
> (This can be changed to return -ENODEV if needed. This patch leaves it at
> -EINVAL to match current behaviour).
> 
> Testing this change requires an iproute2 patch to make dev optional
> during ipv4 neigh adds/dels.
> 
> Reported-by: Jamal Hadi Salim <hadi@mojatatu.com>
> Suggested-by: Jamal Hadi Salim <hadi@mojatatu.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

I think the horse has already exited the barn on this one.

If people start depending upon this new behavior, they will write apps
that do not work on %99.9999999 of the kernels out there.

We are therefore stuck with the current semantics, for good or for
bad.
