From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] vxlan: fix igmp races
Date: Thu, 18 Jul 2013 13:15:48 -0700 (PDT)
Message-ID: <20130718.131548.217898509443978446.davem@davemloft.net>
References: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
	<20130718084015.507bd03c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964966Ab3GRUPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 16:15:49 -0400
In-Reply-To: <20130718084015.507bd03c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 18 Jul 2013 08:40:15 -0700

> There are two race conditions in existing code for doing IGMP
> management in workqueue in vxlan. First, the vxlan_group_used
> function checks the list of vxlan's without any protection, and
> it is possible for open followed by close to occur before the
> igmp work queue runs.
> 
> To solve these move the check into vxlan_open/stop so it is
> protected by RTNL. And split into two work structures so that
> there is no racy reference to underlying device state.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
