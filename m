From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 08 Mar 2007 23:11:42 -0800 (PST)
Message-ID: <20070308.231142.74749203.davem@davemloft.net>
References: <20070308.222154.74746753.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329026E981A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993028AbXCIHLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 02:11:54 -0500
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329026E981A@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 8 Mar 2007 22:42:19 -0800

> This was taken into consideration, and I did reply that my concern for
> doing that could cause stale data in the skb if the queue mapping
> changed.

This is not a problem.

Since the ->enqueue function stores references to the SKBs,
any change of the dev->qdisc has to flush those references
somehow, and it is at that point that you can fixup the
skb queue mappings.

This happens via invoking the qdisc->ops->reset() method.
