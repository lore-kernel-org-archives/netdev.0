From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next 1/1] net: fec: add stop mode request on/off
 implemention
Date: Sun, 26 Jul 2015 16:26:38 -0700 (PDT)
Message-ID: <20150726.162638.1540098306351231379.davem@davemloft.net>
References: <1437560023-9271-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbbGZX0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:26:40 -0400
In-Reply-To: <1437560023-9271-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 22 Jul 2015 18:13:43 +0800

> The current driver depends on platform data to implement stop mode
> request on/off that call api pdata->sleep_mode_enable().
> 
> To reduce arch platform redundancy code, since the function only set
> SOC GPR register bit to request stop mode of/off, so we can move the
> function into driver. And the specifix GPR register offset and MASK
> bit can be transferred from DTS.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Doesn't this break stop mode on those devices until the DTS is
updated?

That's really unfortunate, because you're leaving all of the platform
data and implementation there, yet it's going to be unused.

I really think you need to keep the code using the platform data bits
around until all the DTSs are updated.

No matter what you tell me about how DTSs are updated (don't even
mention the details, I do not care) you simply cannot keep the
platform data code around and not use it.  It is completely
nonsensible to have code that would properly function and properly
support a feature for the device in the kernel, yet not use it.

Period.
