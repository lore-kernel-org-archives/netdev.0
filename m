From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iwlwifi: fix skb truesize underestimation
Date: Fri, 23 Mar 2012 17:22:25 -0700
Message-ID: <1332548545.2516.134.camel@edumazet-glaptop>
References: <1332507112.4858.12.camel@edumazet-laptop>
	 <20120323.143826.1042705555491529895.davem@davemloft.net>
	 <1332528919.2516.2.camel@edumazet-glaptop>
	 <1332547547.2516.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wey-yi.w.guy@intel.com,
	Neal Cardwell <ncardwell@google.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57747 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213Ab2CXAW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 20:22:27 -0400
Received: by iagz16 with SMTP id z16so5352644iag.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 17:22:26 -0700 (PDT)
In-Reply-To: <1332547547.2516.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-23 at 17:05 -0700, Eric Dumazet wrote:
> +	if (len) {
> +		int offset = (void *)hdr + hdrlen - rxb_addr(rxb);
> + 
> +		skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
> +				len, rxb->truesize);
> +	}
>  	iwl_update_stats(priv, false, fc, len);
>  

Please delete this patch, I'll send a v2 : iwl_update_stats() should be
called with original "len", not "len - hdrlen"
