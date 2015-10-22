From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] netlink: Rightsize IFLA_AF_SPEC size
 calculation
Date: Wed, 21 Oct 2015 19:15:32 -0700 (PDT)
Message-ID: <20151021.191532.1097000872602164221.davem@davemloft.net>
References: <1444888204-1954-1-git-send-email-ronen.arad@intel.com>
	<1445271808-9097-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932382AbbJVB7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:59:05 -0400
In-Reply-To: <1445271808-9097-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronen Arad <ronen.arad@intel.com>
Date: Mon, 19 Oct 2015 09:23:28 -0700

> if_nlmsg_size() overestimates the minimum allocation size of netlink
> dump request (when called from rtnl_calcit()) or the size of the
> message (when called from rtnl_getlink()). This is because
> ext_filter_mask is not supported by rtnl_link_get_af_size() and
> rtnl_link_get_size().
> 
> The over-estimation is significant when at least one netdev has many
> VLANs configured (8 bytes for each configured VLAN).
> 
> This patch-set "rightsizes" the protocol specific attribute size
> calculation by propagating ext_filter_mask to rtnl_link_get_af_size()
> and adding this a argument to get_link_af_size op in rtnl_af_ops.
> 
> Bridge module already used filtering aware sizing for notifications.
> br_get_link_af_size_filtered() is consistent with the modified
> get_link_af_size op so it replaces br_get_link_af_size() in br_af_ops.
> br_get_link_af_size() becomes unused and thus removed.
> 
> Signed-off-by: Ronen Arad <ronen.arad@intel.com>

Applied, thanks.
