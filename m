From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: prevent receive getting out of sequence on
 napi poll
Date: Wed, 08 Jul 2015 23:37:13 -0700 (PDT)
Message-ID: <20150708.233713.1843115462537095124.davem@davemloft.net>
References: <1436292138-18190-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbbGIGhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 02:37:14 -0400
In-Reply-To: <1436292138-18190-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue,  7 Jul 2015 14:02:18 -0400

> vmxnet3's current napi path is built to count every rx descriptor we recieve,
> and use that as a count of the napi budget.  That means its possible to return
> from a napi poll halfway through recieving a fragmented packet accross multiple
> dma descriptors.  If that happens, the next napi poll will start with the
> descriptor ring in an improper state (e.g. the first descriptor we look at may
> have the end-of-packet bit set), which will cause a BUG halt in the driver.
> 
> Fix the issue by only counting whole received packets in the napi poll and
> returning that value, rather than the descriptor count.
> 
> Tested by the reporter and myself, successfully
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
