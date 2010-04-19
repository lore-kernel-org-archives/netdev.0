From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] bnx2x: Set default value of num_queues to 1 on
 32-bit platforms
Date: Sun, 18 Apr 2010 23:29:39 -0700 (PDT)
Message-ID: <20100418.232939.59672210.davem@davemloft.net>
References: <1271602224.27235.199.camel@lb-tlvb-vladz>
	<20100418.211023.104052199.davem@davemloft.net>
	<1271657181.27125.20.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075Ab0DSG3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 02:29:36 -0400
In-Reply-To: <1271657181.27125.20.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 19 Apr 2010 09:06:21 +0300

> Yes - running low on vmalloc is the reason. This patch does not restrict
> the usage of multi queue on 32bits - it is just changing the default
> queues values from the number of available CPUs to 1. If the user will
> use another value, it will work as before.

Changing the default to 1 is equivalent to disabling multi-queue.

> We encounter few issues were a 32bit kernel was installed on a
> multi-core platform and the driver allocated "too many" queues. One way
> to go is to limit the queue size and the other is the number of queues -
> leaving it as is caused issues due to running low on kernel virtual
> memory so a change was needed.

Look into using an allocation strategy other than vmalloc(), in fact
I can't see why you need to much memory that vmalloc() must be used
in the first place.
