From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Mon, 11 Jul 2011 20:27:17 -0700 (PDT)
Message-ID: <20110711.202717.1764669415135298036.davem@davemloft.net>
References: <78567a0a1d2999f06d8f.1307768649@meeusr-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronny.meeus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab1GLD1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:27:19 -0400
In-Reply-To: <78567a0a1d2999f06d8f.1307768649@meeusr-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronny Meeus <ronny.meeus@gmail.com>
Date: Sat, 11 Jun 2011 07:04:09 +0200

> I was running a test: 1 application was sending raw Ethernet packets
> on a physical looped interface while a second application was
> receiving packets, so the latter application receives each packet 2
> times (once while sending from the context of the first application
> and a second time while receiving from the hardware).  After some
> time, the test blocks due to a spinlock reentrance issue in
> af_packet. Both the sending application and the softIRQ receiving
> packets enter the spinlock code. After applying the patch below, the
> issue is resolved.
>
> Signed-off-by: Ronny Meeus <ronny.meeus@gmail.com>

The packet receive hooks should always be called with software
interrupts disabled, it is a bug if this is not happening.  Your
patch should not be necessary at all.

