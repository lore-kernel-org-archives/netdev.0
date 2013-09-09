From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: fix bug in sctp_poll for SOCK_SELECT_ERR_QUEUE
Date: Mon, 09 Sep 2013 09:56:12 -0400
Message-ID: <522DD37C.5070108@gmail.com>
References: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:44623 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab3IIN4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 09:56:18 -0400
In-Reply-To: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 10:44 AM, Daniel Borkmann wrote:
> If we do not add braces around ...
>
>    mask |= POLLERR |
>            sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
>
> ... then this condition always evaluates to true as POLLERR is
> defined as 8 and binary or'd with whatever result comes out of
> sock_flag(). Hence instead of (X | Y) ? A : B, transform it into
> X | (Y ? A : B). Unfortunatelty, commit 8facd5fb73 ("net: fix
> smatch warnings inside datagram_poll") forgot about SCTP. :-(
>
> Introduced by 7d4c04fc170 ("net: add option to enable error queue
> packets waking select").
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc Jacob Keller <jacob.e.keller@intel.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/socket.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d5d5882..5462bbb 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6176,7 +6176,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
>   	/* Is there any exceptional events?  */
>   	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
>   		mask |= POLLERR |
> -			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
> +			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
>   	if (sk->sk_shutdown & RCV_SHUTDOWN)
>   		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
>   	if (sk->sk_shutdown == SHUTDOWN_MASK)
>
