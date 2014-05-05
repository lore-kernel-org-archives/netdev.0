From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] unregister_netdevice : move RTM_DELLINK to
 until after ndo_uninit
Date: Mon, 05 May 2014 13:12:28 -0400 (EDT)
Message-ID: <20140505.131228.2110654146298476507.davem@davemloft.net>
References: <1398969630-4808-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	jiri@resnulli.us, tgraf@suug.ch, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbaEERMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 13:12:31 -0400
In-Reply-To: <1398969630-4808-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Thu,  1 May 2014 11:40:30 -0700

> From: roopa <roopa@cumulusnetworks.com>

Please fix your setup so that your real full name appears in the From:
tag, not just 'roopa'.  I fixed it up for you this time.

> This patch fixes ordering of rtnl notifications during unregister_netdevice
> by moving RTM_DELLINK notification to until after ndo_uninit.
> 
> The problem was seen with unregistering bond netdevices.
> 
> bond ndo_uninit callback generates a few RTM_NEWLINK notifications for
> NETDEV_CHANGEADDR and NETDEV_FEAT_CHANGE. This is seen mostly when the
> bond is deleted with slaves still enslaved to the bond.
> 
> During unregister netdevice (rollback_registered_many to be specific)
> bond ndo_uninit is called after RTM_DELLINK notification goes out.
> This results in userspace seeing RTM_DELLINK followed by a couple of
> RTM_NEWLINK's.
> 
> In userspace problem was seen with libnl. libnl cache deletes the bond
> when it sees RTM_DELLINK and re-adds the bond with the following
> RTM_NEWLINK. Resulting in a stale bond entry in libnl cache when the kernel
> has already deleted the bond.
> 
> This patch has been tested for bond, bridges and vlan devices.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
