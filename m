From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Thu, 21 Sep 2017 23:25:36 +0200
Message-ID: <20170921212536.GA814@electric-eye.fr.zoreil.com>
References: <1505985924-12479-1-git-send-email-amine.kherbouche@6wind.com>
 <1505985924-12479-3-git-send-email-amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com,
        equinox@diac24.net
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57370 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751707AbdIUVZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:25:49 -0400
Content-Disposition: inline
In-Reply-To: <1505985924-12479-3-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amine Kherbouche <amine.kherbouche@6wind.com> :
[...]
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 36ea2ad..060ed07 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
[...]
> @@ -39,6 +40,40 @@ static int one = 1;
>  static int label_limit = (1 << 20) - 1;
>  static int ttl_max = 255;
>  
> +size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
> +{
> +	return sizeof(struct mpls_shim_hdr);
> +}
> +
> +int ipgre_mpls_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> +			    u8 *protocol, struct flowi4 *fl4)
> +{
> +	return 0;
> +}
> +
> +static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
> +	.encap_hlen = ipgre_mpls_encap_hlen,
> +	.build_header = ipgre_mpls_build_header,
> +};

Nit: af_mpls.c uses tab before '=' in such places.

> +
> +int ipgre_tunnel_encap_add_mpls_ops(void)
> +{
> +	int ret;
> +
> +	ret = ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);

ip_tunnel_encap_add_ops is CONFIG_NET_IP_TUNNEL dependant.

Afaics CONFIG_MPLS does not enforce it.

[...]
> @@ -2486,6 +2521,7 @@ static int __init mpls_init(void)
>  		      0);
>  	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
>  		      mpls_netconf_dump_devconf, 0);
> +	ipgre_tunnel_encap_add_mpls_ops();
>  	err = 0;
>  out:
>  	return err;

ipgre_tunnel_encap_add_mpls_ops status return code is not checked.

-- 
Ueimor
