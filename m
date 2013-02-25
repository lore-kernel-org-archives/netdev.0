From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: fix ethtool ring buffer size setting
Date: Sun, 24 Feb 2013 20:19:36 -0500 (EST)
Message-ID: <20130224.201936.1455941402175863131.davem@davemloft.net>
References: <1361565144-18301-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759457Ab3BYBTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 20:19:54 -0500
In-Reply-To: <1361565144-18301-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 22 Feb 2013 15:32:24 -0500

> Noticed that vmxnet3's get_ringparam function was returning the summation of all
> ring buffers on a NIC, rather than just the size of any one ring.  This causes
> problems when a vmxnet3 instance has multiple queues, as ethtool, when setting
> ring parameters, first gets the current ring parameters to set the existing
> values in the set_ringparm commannd.  The result is, that unless both rx and tx
> ring sizes are set in a single operation, which ever ring is not set will
> silently have its ring count multiplied by the number of queues on the NIC until
> it reaches a driver defined maxiumum value.
> 
> Fix it by not multiplying the rx and tx ring sizes by the number of queues in
> the system, like every other driver.  Tested by myself successfully.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
