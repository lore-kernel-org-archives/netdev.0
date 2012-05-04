From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] bonding: don't increase rx_dropped after processing
 LACPDUs
Date: Fri, 04 May 2012 15:04:56 +0200
Message-ID: <1336136696.3752.320.camel@edumazet-glaptop>
References: <20120502202309.GA25355@midget.suse.cz>
	 <1335991009.22133.639.camel@edumazet-glaptop>
	 <20120502205118.GB25355@midget.suse.cz>
	 <20120502.194105.1211756092128572035.davem@davemloft.net>
	 <20120504121629.GB32665@midget.suse.cz>
	 <20120504121935.GC32665@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39450 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab2EDNFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 09:05:09 -0400
Received: by bkcji2 with SMTP id ji2so2187236bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 06:05:08 -0700 (PDT)
In-Reply-To: <20120504121935.GC32665@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 14:19 +0200, Jiri Bohac wrote:
> Since commit 3aba891d, bonding processes LACP frames (802.3ad
> mode) with bond_handle_frame(). Currently a copy of the skb is
> made and the original is left to be processed by other
> rx_handlers and the rest of the network stack by returning
> RX_HANDLER_ANOTHER.  As there is no protocol handler for
> PKT_TYPE_LACPDU, the frame is dropped and dev->rx_dropped
> increased.
> 
> Fix this by making bond_handle_frame() return RX_HANDLER_CONSUMED
> if bonding has processed the LACP frame.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 


>  		if (likely(nskb)) {
> -			recv_probe(nskb, bond, slave);
> +			ret = recv_probe(nskb, bond, slave);
>  			dev_kfree_skb(nskb);
> +			if (ret == RX_HANDLER_CONSUMED) {
> +				kfree_skb(skb);

consume_skb(skb) to not fool drop_monitor/dropwatch ?

> +				return ret;
> +			}
>  		}
>  	}
