From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6 7/8] net: introduce rx_handler results and
 logic around that
Date: Sat, 05 Mar 2011 12:48:50 +0000
Message-ID: <1299329330.4277.97.camel@localhost>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
	 <1299320969-7951-8-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6848 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692Ab1CEMsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 07:48:55 -0500
In-Reply-To: <1299320969-7951-8-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-03-05 at 11:29 +0100, Jiri Pirko wrote:
> This patch allows rx_handlers to better signalize what to do next to
> it's caller. That makes skb->deliver_no_wcard no longer needed.
[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -390,7 +390,14 @@ enum gro_result {
>  };
>  typedef enum gro_result gro_result_t;
>  
> -typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
> +enum rx_handler_result {
> +	RX_HANDLER_CONSUMED,
> +	RX_HANDLER_ANOTHER,
> +	RX_HANDLER_EXACT,
> +	RX_HANDLER_PASS,
> +};
[...]

This should have a comment (preferably kernel-doc) clearly specifying
the meaning of each code, as the differences between ANOTHER/EXACT/PASS
are fairly subtle.

Ben,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

