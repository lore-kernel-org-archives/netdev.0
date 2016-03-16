From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 7/7] vxlan: allow setting ipv6 traffic class
Date: Wed, 16 Mar 2016 11:59:52 +0100
Message-ID: <20160316115952.463e851c@griffin>
References: <cover.1457099834.git.daniel@iogearbox.net>
	<c50f1e302411f7e4fe73ec469e0683f3e14fe830.1457099834.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966601AbcCPK76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 06:59:58 -0400
In-Reply-To: <c50f1e302411f7e4fe73ec469e0683f3e14fe830.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Mar 2016 15:15:08 +0100, Daniel Borkmann wrote:
> We can already do that for IPv4, but IPv6 support was missing. Add
> it for vxlan, so it can be used with collect metadata frontends.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  drivers/net/vxlan.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 366a858..d33a434 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1788,7 +1788,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
>  
>  #if IS_ENABLED(CONFIG_IPV6)
>  static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
> -					  struct sk_buff *skb, int oif,
> +					  struct sk_buff *skb, int oif, u8 tos,
>  					  const struct in6_addr *daddr,
>  					  struct in6_addr *saddr,
>  					  struct dst_cache *dst_cache,
> @@ -1799,6 +1799,8 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
>  	struct flowi6 fl6;
>  	int err;
>  
> +	if (tos && !info)
> +		use_cache = false;
>  	if (use_cache) {
>  		ndst = dst_cache_get_ip6(dst_cache, saddr);
>  		if (ndst)
> @@ -1807,6 +1809,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
>  
>  	memset(&fl6, 0, sizeof(fl6));
>  	fl6.flowi6_oif = oif;
> +	fl6.flowi6_tos = RT_TOS(tos);

Nothing against this but the reason it was missing was that it's never
used. Unless I'm missing something the IPv6 code does not use this
field at all for lookups.

This patch is not wrong but it's effectively dead code right now.
I'll be happy to be proven wrong, though.

(Sorry for answering after such long time, I'm catching up after a
vacation.)

 Jiri
