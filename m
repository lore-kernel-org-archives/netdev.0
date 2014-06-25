From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/7] net-timestamp: tx timestamp without payload
Date: Wed, 25 Jun 2014 07:16:48 +0200
Message-ID: <20140625051648.GE3845@localhost.localdomain>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-4-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:51688 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaFYFRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 01:17:13 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so1729450wiv.8
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 22:17:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403624632-17327-4-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 11:43:48AM -0400, Willem de Bruijn wrote:
> Applications receive tx timestamps from the kernel by reading the
> original packet from the socket error queue with sendmsg() and
> processing an ancillary data item that holds the timestamps.
> 
> If the application is only interested in the timestamp, then looping
> the whole packet back up to userspace wastes socket buffer space
> (SO_RCVBUF). This is especially important when the same packet is
> enqueued repeatedly with multiple timestamps.
> 
> This patch adds a socket option to loop the timestamp on top of an
> empty packet instead of a clone of the original.

This makes sense. In practice the looped buffer is totally useless,
due to the fact that many NICs can only handle one outstanding
transmit time stamp. Applications must make sure they only send one
packet at a time if they want every packet time stamped.

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 32cd1be..df7bde0 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -690,6 +690,7 @@ enum sock_flags {
>  	SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
>  	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
>  	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
> +	SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD, /* %SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD */

That is a bit of a mouthful. How about something like:

 SOCK_TIMESTAMPING_PLAIN_TS
 SOCK_TIMESTAMPING_BARE_TS
 SOCK_TIMESTAMPING_TSONLY


Thanks,
Richard
