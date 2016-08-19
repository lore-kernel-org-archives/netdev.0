From: Greg <gvrose8192@gmail.com>
Subject: Re: [net-next PATCH] ethtool: Add support for SCTP verification tag
 in Rx NFC
Date: Fri, 19 Aug 2016 15:05:20 -0700
Message-ID: <1471644320.3338.0.camel@gmail.com>
References: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35192 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755372AbcHSWFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 18:05:22 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so2017228pfg.2
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 15:05:22 -0700 (PDT)
In-Reply-To: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-19 at 14:32 -0700, Alexander Duyck wrote:
> The i40e hardware has support for SCTP filtering via Rx NFC however the
> default configuration expects us to include the verification tag as a part
> of the filter.  In order to support that I need to be able to transfer that
> data through the ethtool interface via a new structure.
> 
> This patch adds a new structure to allow us to pass the verification tag
> for IPv4 or IPv6 SCTP traffic.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/uapi/linux/ethtool.h |   50 +++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 46 insertions(+), 4 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index b8f38e8..12ba8ac 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -708,7 +708,7 @@ enum ethtool_flags {
>   * @pdst: Destination port
>   * @tos: Type-of-service
>   *
> - * This can be used to specify a TCP/IPv4, UDP/IPv4 or SCTP/IPv4 flow.
> + * This can be used to specify a TCP/IPv4 or UDP/IPv4 flow.
>   */
>  struct ethtool_tcpip4_spec {
>  	__be32	ip4src;
> @@ -719,6 +719,27 @@ struct ethtool_tcpip4_spec {
>  };
>  
>  /**
> + * struct ethtool_sctpip4_spec - flow specification for SCTP/IPv4
> + * @ip4src: Source host
> + * @ip4dst: Destination host
> + * @psrc: Source port
> + * @pdst: Destination port
> + * @tos: Type-of-service
> + * @vtag: Verification tag
> + *
> + * This can be used to specify a SCTP/IPv4 flow.
> + */
> +struct ethtool_sctpip4_spec {
> +	__be32	ip4src;
> +	__be32	ip4dst;
> +	__be16	psrc;
> +	__be16	pdst;
> +	__u8    tos;
> +	/* 3 byte hole */
> +	__be32	vtag;
> +};
> +
> +/**
>   * struct ethtool_ah_espip4_spec - flow specification for IPsec/IPv4
>   * @ip4src: Source host
>   * @ip4dst: Destination host
> @@ -762,7 +783,7 @@ struct ethtool_usrip4_spec {
>   * @pdst: Destination port
>   * @tclass: Traffic Class
>   *
> - * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
> + * This can be used to specify a TCP/IPv6 or UDP/IPv6 flow.
>   */
>  struct ethtool_tcpip6_spec {
>  	__be32	ip6src[4];
> @@ -773,6 +794,27 @@ struct ethtool_tcpip6_spec {
>  };
>  
>  /**
> + * struct ethtool_sctpip6_spec - flow specification for SCTP/IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @psrc: Source port
> + * @pdst: Destination port
> + * @tclass: Traffic Class
> + * @vtag: Verification tag
> + *
> + * This can be used to specify a SCTP/IPv6 flow.
> + */
> +struct ethtool_sctpip6_spec {
> +	__be32	ip6src[4];
> +	__be32	ip6dst[4];
> +	__be16	psrc;
> +	__be16	pdst;
> +	__u8    tclass;
> +	/* 3 byte hole */
> +	__be32	vtag;
> +};
> +
> +/**
>   * struct ethtool_ah_espip6_spec - flow specification for IPsec/IPv6
>   * @ip6src: Source host
>   * @ip6dst: Destination host
> @@ -807,13 +849,13 @@ struct ethtool_usrip6_spec {
>  union ethtool_flow_union {
>  	struct ethtool_tcpip4_spec		tcp_ip4_spec;
>  	struct ethtool_tcpip4_spec		udp_ip4_spec;
> -	struct ethtool_tcpip4_spec		sctp_ip4_spec;
> +	struct ethtool_sctpip4_spec		sctp_ip4_spec;
>  	struct ethtool_ah_espip4_spec		ah_ip4_spec;
>  	struct ethtool_ah_espip4_spec		esp_ip4_spec;
>  	struct ethtool_usrip4_spec		usr_ip4_spec;
>  	struct ethtool_tcpip6_spec		tcp_ip6_spec;
>  	struct ethtool_tcpip6_spec		udp_ip6_spec;
> -	struct ethtool_tcpip6_spec		sctp_ip6_spec;
> +	struct ethtool_sctpip6_spec		sctp_ip6_spec;
>  	struct ethtool_ah_espip6_spec		ah_ip6_spec;
>  	struct ethtool_ah_espip6_spec		esp_ip6_spec;
>  	struct ethtool_usrip6_spec		usr_ip6_spec;
> 

Looks good to me.

Reviewed-by: Greg Rose <grose@lightfleet.com>
