From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Mon, 02 Feb 2015 12:38:19 -0500
Message-ID: <54CFB60B.3060800@hp.com>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Hannes Frederic Sowa <hannes@redhat.com>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:44437 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbbBBRiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 12:38:22 -0500
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com [15.217.128.52])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 38B286ECE
	for <netdev@vger.kernel.org>; Mon,  2 Feb 2015 17:38:22 +0000 (UTC)
In-Reply-To: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2015 11:01 PM, David Ahern wrote:
> Currently, all ipv6 addresses are flushed when the interface is configured
> down, even static address:
> 
...
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 2805062c013f..b91b7c8be023 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -53,6 +53,7 @@ struct ipv6_devconf {
>  	__s32           ndisc_notify;
>  	__s32		suppress_frag_ndisc;
>  	__s32		accept_ra_mtu;
> +	__s32		flush_addr_on_down;
>  	void		*sysctl;
>  };
...
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 437a6a4b125a..ed10d4ba8340 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -170,6 +170,7 @@ enum {
>  	DEVCONF_ACCEPT_RA_FROM_LOCAL,
>  	DEVCONF_USE_OPTIMISTIC,
>  	DEVCONF_ACCEPT_RA_MTU,
> +	DEVCONF_FLUSH_ON_DOWN,

nit: DEVCONF_FLUSH_ADDR_ON_DOWN to match the name added to ipv6_devconf.

-Brian
