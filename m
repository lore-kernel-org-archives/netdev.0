From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] sock: ignore TIMESTAMP, RXQ_OVFL, WIFI_STATUS in
 sock_cmsg_send
Date: Fri, 13 May 2016 15:46:15 +0300
Message-ID: <1ffa9a5a-ed5a-dfdf-9d35-1da3b2059df9@cogentembedded.com>
References: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, maze@google.com, willemb@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33825 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcEMMqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 08:46:19 -0400
Received: by mail-lf0-f53.google.com with SMTP id m64so87543044lfd.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 05:46:18 -0700 (PDT)
In-Reply-To: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/13/2016 7:47 AM, Soheil Hassas Yeganeh wrote:

> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> SO_TIMESTAMP(NS), RXQ_OVFL, and WIFI_STATUS can be returned as
> receive-side control messages from recvmsg(). Although invalid,
> some applications may reflect those receive-side control messages
> back to sendmsg(). Since socket-level control messages were being
> ignored in ipv4 and ipv6, such applications would not get an error.
>
> 24025c4 (ipv4: process socket-level control messages in IPv4) and
> ad1e46 (ipv6: process socket-level control messages in IPv6) add

    scripts/checkpatch.pl now enforces certain commit citing style, yours 
doesn't quite match -- SHA1 should be at least 12 digits and the summary 
enclosed in ("").

> support for socket-level control messages in ipv4 and ipv6 on
> sendmsg(). This results in getting -EINVAL, if the application
> passes in a message with SO_WIFI_STATUS, SO_RXQ_OVFL, SO_TIMESTAMP
> and/or SO_TIMESTAMPNS that might have been received in recvmsg().
>
> Ignore SO_WIFI_STATUS, SO_TIMESTAMP(NS), and SO_RXQ_OVFL when
> processing socket-level control messages in send-side to remain
> backward compatible.
> ---
>  net/core/sock.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08bf97e..1e0bcd0 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1938,6 +1938,12 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
>  		sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
>  		sockc->tsflags |= tsflags;
>  		break;
> +	/* Ignore the following types on send to remain backward compatible. */
> +	case SO_RXQ_OVFL:	/* Fall through */
> +	case SO_TIMESTAMP:	/* Fall through */
> +	case SO_TIMESTAMPNS:	/* Fall through */
                                 ^^^^^^^^^^^^^^^^^^
    There's no need for such comments here.

> +	case SO_WIFI_STATUS:
> +		break;
>  	default:
>  		return -EINVAL;
>  	}

MBR, Sergei
