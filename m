From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: Zero flows on allocation.
Date: Tue, 22 Sep 2015 17:34:06 -0700 (PDT)
Message-ID: <20150922.173406.335952800771776043.davem@davemloft.net>
References: <1442892080-68516-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759758AbbIWAeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 20:34:07 -0400
In-Reply-To: <1442892080-68516-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon, 21 Sep 2015 20:21:20 -0700

> When support for megaflows was introduced, OVS needed to start
> installing flows with a mask applied to them. Since masking is an
> expensive operation, OVS also had an optimization that would only
> take the parts of the flow keys that were covered by a non-zero
> mask. The values stored in the remaining pieces should not matter
> because they are masked out.
> 
> While this works fine for the purposes of matching (which must always
> look at the mask), serialization to netlink can be problematic. Since
> the flow and the mask are serialized separately, the uninitialized
> portions of the flow can be encoded with whatever values happen to be
> present.
> 
> In terms of functionality, this has little effect since these fields
> will be masked out by definition. However, it leaks kernel memory to
> userspace, which is a potential security vulnerability. It is also
> possible that other code paths could look at the masked key and get
> uninitialized data, although this does not currently appear to be an
> issue in practice.
> 
> This removes the mask optimization for flows that are being installed.
> This was always intended to be the case as the mask optimizations were
> really targetting per-packet flow operations.
> 
> Fixes: 03f0d916 ("openvswitch: Mega flow implementation")
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied and queued up for -stable, thanks.
