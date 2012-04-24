From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tx transfer padding for full-speed USB
Date: Tue, 24 Apr 2012 00:28:08 -0400 (EDT)
Message-ID: <20120424.002808.1711965470884592541.davem@davemloft.net>
References: <1334916021-9124-1-git-send-email-inguin@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: inguin@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab2DXE2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:28:13 -0400
In-Reply-To: <1334916021-9124-1-git-send-email-inguin@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo van Lil <inguin@gmx.de>
Date: Fri, 20 Apr 2012 12:00:21 +0200

> -	padlen = ((skb->len + 4) % 512) ? 0 : 4;
> +	padlen = ((skb->len + 4) % dev->maxpacket) ? 0 : 4;

This is now an expensive modulus operation, instead of
a cheap mask.

Since you know that dev->maxpacket is always a power of two, tell the
compiler this so it can still optimize the expression by changing this
to "& (dev->maxpacket - 1)" and we'll thus avoid the costly modulus.
