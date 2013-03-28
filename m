From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] net: fix compile error of implicit declaration
 of skb_probe_transport_header
Date: Thu, 28 Mar 2013 11:12:06 +0800
Message-ID: <5153B506.40105@redhat.com>
References: <1364438766-14042-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab3C1DMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 23:12:16 -0400
In-Reply-To: <1364438766-14042-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2013 10:46 AM, Ying Xue wrote:
> The commit 40893fd(net: switch to use skb_probe_transport_header())
> involes a new error accidently. When NET_SKBUFF_DATA_USES_OFFSE is
> not enabled, below compile error happens:
>
>   CC      net/packet/af_packet.o
>   net/packet/af_packet.c: In function =91packet_sendmsg_spkt=92:
>   net/packet/af_packet.c:1516:2: error: implicit declaration of funct=
ion =91skb_probe_transport_header=92 [-Werror=3Dimplicit-function-decla=
ration]
>   cc1: some warnings being treated as errors
>   make[2]: *** [net/packet/af_packet.o] Error 1
>   make[1]: *** [net/packet] Error 2
>   make: *** [net] Error 2
>
> As it seems skb_probe_transport_header() is not related to
> NET_SKBUFF_DATA_USES_OFFSE, we should move the definition of
> skb_probe_transport_header() out of scope of
> NET_SKBUFF_DATA_USES_OFFSE macro.
>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
>  include/linux/skbuff.h |   26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)

Oops.

Acked-by: Jason Wang <jasowang@redhat.com>

Thanks
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index fa88b96..878e0ee 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1560,19 +1560,6 @@ static inline void skb_set_transport_header(st=
ruct sk_buff *skb,
>  	skb->transport_header +=3D offset;
>  }
> =20
> -static inline void skb_probe_transport_header(struct sk_buff *skb,
> -					      const int offset_hint)
> -{
> -	struct flow_keys keys;
> -
> -	if (skb_transport_header_was_set(skb))
> -		return;
> -	else if (skb_flow_dissect(skb, &keys))
> -		skb_set_transport_header(skb, keys.thoff);
> -	else
> -		skb_set_transport_header(skb, offset_hint);
> -}
> -
>  static inline unsigned char *skb_network_header(const struct sk_buff=
 *skb)
>  {
>  	return skb->head + skb->network_header;
> @@ -1716,6 +1703,19 @@ static inline void skb_set_mac_header(struct s=
k_buff *skb, const int offset)
>  }
>  #endif /* NET_SKBUFF_DATA_USES_OFFSET */
> =20
> +static inline void skb_probe_transport_header(struct sk_buff *skb,
> +					      const int offset_hint)
> +{
> +	struct flow_keys keys;
> +
> +	if (skb_transport_header_was_set(skb))
> +		return;
> +	else if (skb_flow_dissect(skb, &keys))
> +		skb_set_transport_header(skb, keys.thoff);
> +	else
> +		skb_set_transport_header(skb, offset_hint);
> +}
> +
>  static inline void skb_mac_header_rebuild(struct sk_buff *skb)
>  {
>  	if (skb_mac_header_was_set(skb)) {
