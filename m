From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: make operstate and carrier more accurate
Date: Fri, 29 Jan 2016 12:07:27 -0800 (PST)
Message-ID: <20160129.120727.2297321341636437499.davem@davemloft.net>
References: <1453913443-4934-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, kaber@trash.net,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbcA2UHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 15:07:30 -0500
In-Reply-To: <1453913443-4934-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 27 Jan 2016 17:50:43 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Currently when a macvlan is being initialized and the lower device is
> netif_carrier_ok(), the macvlan device doesn't run through
> rfc2863_policy() and is left with UNKNOWN operstate. Fix it by adding an
> unconditional linkwatch event for the new macvlan device. Similar fix is
> already used by the 8021q device (see register_vlan_dev()). Also fix the
> inconsistent state when the lower device has been down and its carrier
> was changed (when a device is down NETDEV_CHANGE doesn't get generated).
> The second issue can be seen f.e. when we have a macvlan on top of a 8021q
> device which has been down and its real device has been changing carrier
> states, after setting the 8021q device up, the macvlan device will have
> the same carrier state as it was before even though the 8021q can now
> have a different state.
 ...
> This behaviour seems to have been present since beginning of git history.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks Nikolay.
