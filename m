From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3 net-2.6.26] [IPV4]: Remove unused ip_options->is_data.
Date: Tue, 4 Mar 2008 14:08:10 -0500
Message-ID: <200803041408.10815.paul.moore@hp.com>
References: <1204633289.16891.7.camel@iris.sw.ru> <1204633326-17397-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33381 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764084AbYCDTIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 14:08:11 -0500
In-Reply-To: <1204633326-17397-2-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 March 2008 7:22:05 am Denis V. Lunev wrote:
> ip_options->is_data is assigned only and never checked. The structure
> is not a part of kernel interface to the user. So, it is safe to
> remove this field.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

See my previous comment about folding patch #1 into this one.  Other 
than that I don't have any problem with changes from a CIPSO point of 
view with the current code base.  If we need to do something crazy in 
the future with IPv4 options we can always tackle it then. 

> ---
>  include/net/inet_sock.h |    3 +--
>  net/ipv4/cipso_ipv4.c   |    1 -
>  net/ipv4/ip_options.c   |    5 -----
>  3 files changed, 1 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 70013c5..07ce114 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -43,8 +43,7 @@ struct ip_options {
>  	unsigned char	srr;
>  	unsigned char	rr;
>  	unsigned char	ts;
> -	unsigned char	is_data:1,
> -			is_strictroute:1,
> +	unsigned char	is_strictroute:1,
>  			srr_is_hit:1,
>  			is_changed:1,
>  			rr_needaddr:1,
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index 8cd357f..4637ded 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1800,7 +1800,6 @@ int cipso_v4_sock_setattr(struct sock *sk,
>  	}
>  	memcpy(opt->__data, buf, buf_len);
>  	opt->optlen = opt_len;
> -	opt->is_data = 1;
>  	opt->cipso = sizeof(struct iphdr);
>  	kfree(buf);
>  	buf = NULL;
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index d03eec6..0bf097b 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -45,7 +45,6 @@ void ip_options_build(struct sk_buff * skb, struct
> ip_options * opt, memcpy(&(IPCB(skb)->opt), opt, sizeof(struct
> ip_options)); memcpy(iph+sizeof(struct iphdr), opt->__data,
> opt->optlen); opt = &(IPCB(skb)->opt);
> -	opt->is_data = 0;
>
>  	if (opt->srr)
>  		memcpy(iph+opt->srr+iph[opt->srr+1]-4, &daddr, 4);
> @@ -95,8 +94,6 @@ int ip_options_echo(struct ip_options * dopt,
> struct sk_buff * skb)
>
>  	memset(dopt, 0, sizeof(struct ip_options));
>
> -	dopt->is_data = 1;
> -
>  	sopt = &(IPCB(skb)->opt);
>
>  	if (sopt->optlen == 0) {
> @@ -265,7 +262,6 @@ int ip_options_compile(struct ip_options * opt,
> struct sk_buff * skb) iph = skb_network_header(skb);
>  		opt->optlen = ((struct iphdr *)iph)->ihl*4 - sizeof(struct iphdr);
>  		optptr = iph + sizeof(struct iphdr);
> -		opt->is_data = 0;
>  	} else {
>  		optptr = opt->__data;
>  		iph = optptr - sizeof(struct iphdr);
> @@ -519,7 +515,6 @@ static int ip_options_get_finish(struct
> ip_options **optp, while (optlen & 3)
>  		opt->__data[optlen++] = IPOPT_END;
>  	opt->optlen = optlen;
> -	opt->is_data = 1;
>  	if (optlen && ip_options_compile(opt, NULL)) {
>  		kfree(opt);
>  		return -EINVAL;



-- 
paul moore
linux security @ hp
