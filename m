From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Create right mask with disabled
 megaflows
Date: Fri, 17 Oct 2014 16:20:58 -0400 (EDT)
Message-ID: <20141017.162058.9617975607356013.davem@davemloft.net>
References: <1413521745-1492-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddiproietto@vmware.com, azhou@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbaJQUU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:20:59 -0400
In-Reply-To: <1413521745-1492-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 16 Oct 2014 21:55:45 -0700

> If megaflows are disabled, the userspace does not send the netlink attribute
> OVS_FLOW_ATTR_MASK, and the kernel must create an exact match mask.
> 
> sw_flow_mask_set() sets every bytes (in 'range') of the mask to 0xff, even the
> bytes that represent padding for struct sw_flow, or the bytes that represent
> fields that may not be set during ovs_flow_extract().
> This is a problem, because when we extract a flow from a packet,
> we do not memset() anymore the struct sw_flow to 0.
> 
> This commit gets rid of sw_flow_mask_set() and introduces mask_set_nlattr(),
> which operates on the netlink attributes rather than on the mask key. Using
> this approach we are sure that only the bytes that the user provided in the
> flow are matched.
> 
> Also, if the parse_flow_mask_nlattrs() for the mask ENCAP attribute fails, we
> now return with an error.
> 
> This bug is introduced by commit 0714812134d7dcadeb7ecfbfeb18788aa7e1eaac
> ("openvswitch: Eliminate memset() from flow_extract").
> 
> Reported-by: Alex Wang <alexw@nicira.com>
> Signed-off-by: Daniele Di Proietto <ddiproietto@vmware.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Why are you targetting a bug fix like this to net-next?

That makes no sense at all.
