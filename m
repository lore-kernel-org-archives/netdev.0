From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] vxlan: Eliminate dependency on UDP socket
 in transmit path
Date: Mon, 19 Jan 2015 08:59:38 +0000
Message-ID: <20150119085938.GG20315@casper.infradead.org>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
 <1421518700-22460-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54619 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbASI7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 03:59:40 -0500
Content-Disposition: inline
In-Reply-To: <1421518700-22460-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/15 at 10:18am, Tom Herbert wrote:
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 7be8c34..2927d62 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -129,8 +129,12 @@ struct vxlan_sock {
>  #define VXLAN_F_REMCSUM_RX		0x400
>  #define VXLAN_F_GBP			0x800
>  
> -/* These flags must match in order for a socket to be shareable */
> -#define VXLAN_F_UNSHAREABLE		VXLAN_F_GBP
> +/* Flags that are used in the receive patch. These flags must match in
                                          ^^^^^



> + * order for a socket to be shareable
> + */
> +#define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
> +					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
> +					 VXLAN_F_REMCSUM_RX)

I'm fine with this. It is slightly odd that we will be transmitting
RCO and other extensions on UDP ports which cannot accept the same
frames. I assume you have specific use cases for this scenario.
