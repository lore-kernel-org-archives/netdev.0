From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 12:44:10 -0700 (PDT)
Message-ID: <20150831.124410.99199729741650263.davem@davemloft.net>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	tom@herbertland.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbHaToL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:44:11 -0400
In-Reply-To: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 31 Aug 2015 09:29:40 -0700

> Remove the VRF change in udp_sendmsg to set the source address. The VRF
> driver already has access to the packet on the TX path via the dst. It
> can be used to update the source address in the header.
> 
> Update function based on OVS.
> 
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

This is worse.

You have the source address in the VRF driver's output routine in
fl4.saddr, just use it as-is.

You're adding even more route lookups, at least the existing code
just walks the device address less which is often cheaper than
a full-blown route lookup.
