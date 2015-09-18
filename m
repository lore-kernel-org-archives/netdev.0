From: David Miller <davem@davemloft.net>
Subject: Re: xfrm4_garbage_collect reaching limit
Date: Thu, 17 Sep 2015 21:23:35 -0700 (PDT)
Message-ID: <20150917.212335.346651920275379240.davem@davemloft.net>
References: <20150911094808.GI25499@secunet.com>
	<CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
	<20150916084541.GB7701@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.streetman@canonical.com, ddstreet@ieee.org,
	jay.vosburgh@canonical.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbbIREXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:23:36 -0400
In-Reply-To: <20150916084541.GB7701@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 16 Sep 2015 10:45:41 +0200

> index 1e06c4f..3dffc73 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -248,7 +248,7 @@ static struct dst_ops xfrm4_dst_ops = {
>  	.destroy =		xfrm4_dst_destroy,
>  	.ifdown =		xfrm4_dst_ifdown,
>  	.local_out =		__ip_local_out,
> -	.gc_thresh =		32768,
> +	.gc_thresh =		INT_MAX,
>  };
>  
>  static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {

This means the dst_ops->gc() for xfrm will never be invoked.

Is that intentional?
