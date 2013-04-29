From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] tipc: tipc_bcbearer_send(): simplify bearer
 selection
Date: Mon, 29 Apr 2013 15:44:46 -0400 (EDT)
Message-ID: <20130429.154446.855221874054199436.davem@davemloft.net>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com,
	holger.brunck@keymile.com
To: gerlando.falauto@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761002Ab3D2Tot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:44:49 -0400
In-Reply-To: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerlando Falauto <gerlando.falauto@keymile.com>
Date: Mon, 29 Apr 2013 16:13:39 +0200

> Also some minor cosmetic improvements and comment style changes
> 
> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>

You're mixing too many things, and actually adding style problems.

>  		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
> +		struct tipc_bearer *b = p;
>  		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;

Local variable declarations should be ordered from longest line
to shortest line.

> -		tipc_nmap_diff(&bcbearer->remains, &p->nodes, &bcbearer->remains_new);
> +		tipc_nmap_diff(&bcbearer->remains, &b->nodes,
> +			&bcbearer->remains_new);

This second line is indented incorrectly, do it like this:

	func(arg1, arg2,
	     arg3, arg4);

Specifically arg3 is aligned, using the appropriate mixture of TAB
and space characters, with the first column after the openning
parenthesis of the func() call.

>  		if (bcbearer->remains_new.count == bcbearer->remains.count)
> -			continue;	/* bearer pair doesn't add anything */
> +			continue;  /* Nothing added by bearer pair */

Why is two spaces better than a TAB, make it one space if you're going
to change this.

>  		if (bcbearer->remains_new.count == 0)
> -			break;	/* all targets reached */
> +			break;	/* All targets reached */

Untab this gap between break; and the comment into a space too.
