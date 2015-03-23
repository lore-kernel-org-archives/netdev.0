From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] virtio net: Handle proto_down state by
 setting the carrier off.
Date: Mon, 23 Mar 2015 16:50:01 -0400 (EDT)
Message-ID: <20150323.165001.2063467454200119106.davem@davemloft.net>
References: <1426997218-27313-3-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbbCWUuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:50:04 -0400
In-Reply-To: <1426997218-27313-3-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: anuradhak@cumulusnetworks.com
Date: Sat, 21 Mar 2015 21:06:57 -0700

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> 
> Applications such as MLAG can detect errors in the network which results
> in IFF_PROTO_DOWN being set. This patch adds support for handling
> proto_down for virtio drivers by turning off the carrier and stopping
> netif processing.
> 
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

I really don't like the idea that there are potentially many drivers
that will not have to add this kind of new code.

This doesn't scale when you have dozens of software devices of various
types, and several hundred physical hardware networking drivers.
