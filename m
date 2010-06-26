From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Fri, 25 Jun 2010 21:36:04 -0700 (PDT)
Message-ID: <20100625.213604.186329332.davem@davemloft.net>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51877
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751064Ab0FZEfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:35:51 -0400
In-Reply-To: <1277003136-5522-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Sun, 20 Jun 2010 05:05:36 +0200

> Gcc is currenlty not in the ability to optimize the switch statement in
> sk_run_filter() because of dense case labels. This patch replace the
> OR'd labels with ordered sequenced case labels. The sk_chk_filter()
> function is modified to patch/replace the original OPCODES in a
> ordered but equivalent form. gcc is now in the ability to transform the
> switch statement in sk_run_filter into a jump table of complexity O(1).
> 
> Until this patch gcc generates a sequence of conditional branches (O(n) of 567
> byte .text segment size (arch x86_64):
 ...
> With the modification the compiler translate the switch statement into
> the following jump table fragment:
 ...
> Furthermore, I reordered the instructions to reduce cache line misses by
> order the most common instruction to the start.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied.
