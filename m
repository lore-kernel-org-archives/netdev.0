From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 9 Apr 2017 15:46:55 +0200
Message-ID: <20170409134655.GA2133@lunn.ch>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51327 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752075AbdDINq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 09:46:59 -0400
Content-Disposition: inline
In-Reply-To: <20170408.200721.109499285021338999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	switch (act) {
> +	case XDP_PASS:
> +	case XDP_TX:
> +		break;
> +
> +	default:
> +		bpf_warn_invalid_xdp_action(act);

Hi David

You might want to put a /* fall through */ comment here, just to
prevent newbies from submitting patches moving the default clause to
the end.

    Andrew

> +	case XDP_ABORTED:
> +		trace_xdp_exception(skb->dev, xdp_prog, act);
> +	case XDP_DROP:
> +	do_drop:
> +		kfree_skb(skb);
> +		break;
> +	}
> +
> +	return act;
> +}
