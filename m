From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tipc: Optimize handling excess content on
 incoming messages
Date: Fri, 03 Sep 2010 12:55:33 -0700 (PDT)
Message-ID: <20100903.125533.173857867.davem@davemloft.net>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
	<1283538822-25718-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753967Ab0ICTzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 15:55:16 -0400
In-Reply-To: <1283538822-25718-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  3 Sep 2010 14:33:41 -0400

> @@ -248,6 +248,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
>  
>  	/* Handle message for another node */
>  	msg_dbg(msg, "NET>SEND>: ");
> +	pskb_trim(buf, msg_size(msg));
>  	tipc_link_send(buf, dnode, msg_link_selector(msg));
>  }

1) pskb_trim() can fail, you need to check the return value
   and act appropriately.

2) pskb_trim() can change all of the packet data pointers, so
   after you call it you need to reload any pointers to the
   packet data area.  At a minimum, you woull need to
   reload 'msg' in this code snippet.

   Otherwise 'msg' can point to freed up memory after the call.
