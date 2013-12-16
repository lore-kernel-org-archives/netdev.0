From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC v2 08/13] xfrm: Add xfrm_tunnel_skb_cb to the skb
 common buffer
Date: Mon, 16 Dec 2013 13:54:10 +0100
Message-ID: <52AEF7F2.6040903@6wind.com>
References: <20131216091835.GQ31491@secunet.com> <20131216092349.GY31491@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:44509 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983Ab3LPMyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:54:13 -0500
Received: by mail-wi0-f179.google.com with SMTP id z2so2065308wiv.0
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 04:54:12 -0800 (PST)
In-Reply-To: <20131216092349.GY31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/12/2013 10:23, Steffen Klassert a =E9crit :
> IPsec vti_rcv needs to remind the tunnel pointer to
> check it later at the vti_rcv_cb callback. So add
> this pointer to the IPsec common buffer.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   include/net/xfrm.h |   29 +++++++++++++++++------------
>   1 file changed, 17 insertions(+), 12 deletions(-)
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 2c39cd4..584d0ee4 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -600,16 +600,27 @@ struct xfrm_mgr {
>   int xfrm_register_km(struct xfrm_mgr *km);
>   int xfrm_unregister_km(struct xfrm_mgr *km);
>
> +struct xfrm_tunnel_skb_cb {
> +	union {
> +		struct inet_skb_parm h4;
> +		struct inet6_skb_parm h6;
> +        } header;
Nitpicking: this line is aligned with spaces instead tabs (yes, it's
a copy and paste ;-)).
