From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH][net-next] tcp: remove the duplicate prefixes in the logging
 message
Date: Wed, 23 Apr 2014 11:35:57 +0200
Message-ID: <5357897D.8060809@redhat.com>
References: <1398245335-18780-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbaDWJgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 05:36:14 -0400
In-Reply-To: <1398245335-18780-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 11:28 AM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> The current message is:
> 	TCP: TCP: Possible SYN flooding on port 80. Sending cookies. ...
>
> The cause is that pr_info will implicitly print the pr_fmt string, which is standard
> prefix, and explicitly print the "proto" which is "TCP:" too
>
> it is unsuitable to not print proto, since proto maybe TCPv6, so use printk directly.

Can't you just leave the pr_info() instead, and reword that into something like:

   "Possible %s SYN flooding[...]", proto

> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv4/tcp_ipv4.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 438f3b9..85ebe68 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -892,8 +892,8 @@ bool tcp_syn_flood_action(struct sock *sk,
>   	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
>   	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
>   		lopt->synflood_warned = 1;
> -		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
> -			proto, ntohs(tcp_hdr(skb)->dest), msg);
> +		printk(KERN_INFO "%s: Possible SYN flooding on port %d. %s. Check SNMP counters.\n",
> +		       proto, ntohs(tcp_hdr(skb)->dest), msg);
>   	}
>   	return want_cookie;
>   }
>
