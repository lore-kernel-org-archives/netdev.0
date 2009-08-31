From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] Revert Backoff [v3]: Rename skb to icmp_skb in
 tcp_v4_err()
Date: Mon, 31 Aug 2009 16:22:58 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0908311538050.29341@wel-95.cs.helsinki.fi>
References: <4A950B7B.4010601@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-675611464-1251722494=:29341"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38752 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbZHaNW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 09:22:57 -0400
In-Reply-To: <4A950B7B.4010601@tvk.rwth-aachen.de>
Content-ID: <alpine.DEB.2.00.0908311622130.29341@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-675611464-1251722494=:29341
Content-Type: TEXT/PLAIN; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0908311619501.29341@wel-95.cs.helsinki.fi>

On Wed, 26 Aug 2009, Damian Lukowski wrote:

> This supplementary patch renames skb to icmp_skb in tcp_v4_err() in order to
> disambiguate from another sk_buff variable, which will be introduced
> in a separate patch.
>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
> net/ipv4/tcp_ipv4.c |   16 ++++++++--------
> 1 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 6d88219..6ca1bc8 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -328,26 +328,26 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
>  *
>  */
>
> -void tcp_v4_err(struct sk_buff *skb, u32 info)
> +void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> {
> -	struct iphdr *iph = (struct iphdr *)skb->data;
> -	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
> +	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
> +	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
> 	struct tcp_sock *tp;
> 	struct inet_sock *inet;
> -	const int type = icmp_hdr(skb)->type;
> -	const int code = icmp_hdr(skb)->code;
> +	const int type = icmp_hdr(icmp_skb)->type;
> +	const int code = icmp_hdr(icmp_skb)->code;
> 	struct sock *sk;
> 	__u32 seq;
> 	int err;
> -	struct net *net = dev_net(skb->dev);
> +	struct net *net = dev_net(icmp_skb->dev);
>
> -	if (skb->len < (iph->ihl << 2) + 8) {
> +	if (icmp_skb->len < (iph->ihl << 2) + 8) {

Not that related to the purpose of this patch but still worth to 
mention now that we are in the context... ...I wonder if this should be 
pskb_may_pull instead of direct compare here regardless of this change?

> 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> 		return;
> 	}
>
> 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
> -			iph->saddr, th->source, inet_iif(skb));
> +			iph->saddr, th->source, inet_iif(icmp_skb));
> 	if (!sk) {
> 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> 		return;
>

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
  i.
--8323329-675611464-1251722494=:29341--
