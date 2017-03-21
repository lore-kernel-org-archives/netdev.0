From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/2] gtp: rename SGSN netlink attribute
Date: Tue, 21 Mar 2017 16:07:48 +0100
Message-ID: <20170321150748.GA20384@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170321150430.23314-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47590 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758038AbdCUPH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:07:59 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 40883174D1B
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:07:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2F981DA871
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:07:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7069DDA862
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:07:48 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170321150430.23314-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 04:04:29PM +0100, Jonas Bonn wrote:
> diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
> index 72a04a0..c51ebb0 100644
> --- a/include/uapi/linux/gtp.h
> +++ b/include/uapi/linux/gtp.h
> @@ -19,7 +19,7 @@ enum gtp_attrs {
>  	GTPA_LINK,
>  	GTPA_VERSION,
>  	GTPA_TID,	/* for GTPv0 only */
> -	GTPA_SGSN_ADDRESS,
> +	GTPA_PEER_ADDRESS,	/* Remote GSN peer, either SGSN or GGSN */

We need here:

#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS

for backward compatibility. Anything that is exposed through uapi
cannot be changed.

>  	GTPA_MS_ADDRESS,
>  	GTPA_FLOW,
>  	GTPA_NET_NS_FD,
> @@ -29,5 +29,6 @@ enum gtp_attrs {
>  	__GTPA_MAX,
>  };
>  #define GTPA_MAX (__GTPA_MAX + 1)
> +#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS /* maintain legacy attr name */
>  
>  #endif /* _UAPI_LINUX_GTP_H_ */
> -- 
> 2.9.3
> 
