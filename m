From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [CCID-2]: Remove ccid2hc{tx,rx}_ prefixes
Date: Tue, 27 May 2008 06:25:36 -0700 (PDT)
Message-ID: <20080527.062536.64095383.davem@davemloft.net>
References: <1211877167-10995-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757168AbYE0NZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:25:40 -0400
In-Reply-To: <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:42 +0100

> This patch fixes two problems caused by the ubiquitous long "hctx->ccid2htx_"
> and "hcrx->ccid2hcrx_" prefixes:
>  * code becomes hard to read;
>  * multiple-line statements are almost inevitable even for simple expressions;
> The prefixes are not really necessary (compare with "struct tcp_sock").
> 
> There had been previous discussion of this on dccp@vger, but so far this was
> not followed up (most people agreed that the prefixes are too long).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Leandro Melo de Sales <leandroal@gmail.com>

You're the dccp maintainer, but...

The whole reason we use these member prefixes is so that the
tree is actually greppable.  tcp_sock is the way it is because
we never enforced this useful policy back when it was originally
created.

If you use short member names, it becomes eventually impossible
to grep for "->foo" and have it not match a ton of crap you
are completely not interested in.  Using a prefix creates a
struct member namespace, and thus fixes that problem.

Use editor macros if you don't want to type so much :-)

