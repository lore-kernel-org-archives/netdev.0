From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/20] net-core: extending (hw_/wanted_/vlan_)features
 fields to a bitmap.
Date: Wed, 06 Apr 2011 02:27:51 +0100
Message-ID: <1302053271.2935.152.camel@localhost>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
	 <1302050665-10460-2-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53661 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab1DFB1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 21:27:54 -0400
In-Reply-To: <1302050665-10460-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 17:44 -0700, Mahesh Bandewar wrote:
> Converting current use of (hw_/wanted_/vlan_)features to
> legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.
[...]
> @@ -1029,44 +1065,51 @@ struct net_device {
>  	struct list_head	napi_list;
>  	struct list_head	unreg_list;
>  
> +#define DEV_FEATURE_WORDS	2
> +#define	DEV_FEATURE_BITS	(DEV_FEATURE_WORDS*sizeof(long)*BITS_PER_BYTE)
> +#define LEGACY_FEATURE_WORD	0
> +
>  	/* currently active device features */
> -	u32			features;
> +	unsigned long 		features;
>  	/* user-changeable features */
> -	u32			hw_features;
> +	DECLARE_BITMAP(hw_feature, DEV_FEATURE_BITS);
[...]

Sorry, you can't get rid of hw_features without converting all the
callers at the same time.  All code has to remain compilable after each
single commit.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

