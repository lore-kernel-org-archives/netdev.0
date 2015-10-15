From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Rightsize IFLA_AF_SPEC size calculation
Date: Wed, 14 Oct 2015 18:44:11 -0700 (PDT)
Message-ID: <20151014.184411.1172845560887990370.davem@davemloft.net>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbJOB2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:28:05 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronen Arad <ronen.arad@intel.com>
Date: Tue, 13 Oct 2015 22:58:30 -0700

> if_nlmsg_size() overestimates the minimum allocation size of netlink dump
> request (when called from rtnl_calcit()) or the size of the message (when called
> from rtnl_getlink()). This is because ext_filter_mask is not supported by
> rtnl_link_get_af_size() and rtnl_link_get_size().
> 
> The over-estimation is significant when at least one netdev has many VLANs
> configured (8 bytes for each configured VLAN).
> 
> This patch-set "rightsizes" the protocol specific attribute size calculation by
> propagating ext_filter_mask to rtnl_link_get_af_size() and adding optional
> filtering aware get_af_size_filtered op in struct rtnl_af_ops. Bridge module,
> which already used filtering aware sizing for notification, is enhanced to do
> the same for netlink dump requests.

There are only three implementations of get_link_af_size, so please just simply
change it's signature by adding the ext_filter_mask parameter instead of creating
a completely new operation.
