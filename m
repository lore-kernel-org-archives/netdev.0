From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu, 03 Feb 2011 14:21:45 -0800 (PST)
Message-ID: <20110203.142145.183054407.davem@davemloft.net>
References: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52650
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754440Ab1BCWVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 17:21:10 -0500
In-Reply-To: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Thu,  3 Feb 2011 16:45:17 -0200

> It's possible to trigger a crash if one CPU is opening
> the device while another CPU gets its statistics.
> 
> It happens because niu_alloc_channels() called from
> niu_open() sets num_tx/rx_rings before allocating the
> ring, so the other thread crashes when accessing
> np->tx_rings[i].tx_packets at niu_get_tx_stats().
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
 ...
> Compile tested only because I don't have the hardware.

I'll apply this and give it a quick test, thanks.

Can you have the person who reported this crash to you test the patch
out at least?  That's how you learned about this problem, right,
someone else hit the crash?

In such cases I'd really appreciate it if you got positive testing
feedback from the reporter before posting the patch.

Longer term a better way to fix this is to RCU free the ring data
structures, and use a quick NULL test at the top of the get stats
implementation.

