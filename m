From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: ethernet: aquantia: fix alloc_cast.cocci warnings
Date: Fri, 20 Jan 2017 00:19:57 -0800
Message-ID: <1484900397.12563.1.camel@perches.com>
References: <201701191708.e8q1JvlR%fengguang.wu@intel.com>
         <20170119090931.GA28354@lkp-ne04.lkp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        David VomLehn <vomlehn@texas.net>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: kbuild test robot <lkp@intel.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0220.hostedemail.com ([216.40.44.220]:51771 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751499AbdATIUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 03:20:01 -0500
In-Reply-To: <20170119090931.GA28354@lkp-ne04.lkp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 17:09 +0800, kbuild test robot wrote:
> drivers/net/ethernet/aquantia/atlantic/aq_ring.c:24:20-41: WARNING: casting value returned by memory allocation function to (struct aq_ring_buff_s *) is useless.
> 
>  Remove casting the values returned by memory allocation functions
>  like kmalloc, kzalloc, kmem_cache_alloc, kmem_cache_zalloc etc.
[]
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> @@ -21,7 +21,7 @@ static struct aq_ring_s *aq_ring_alloc(s
>  {
>  	int err = 0;
>  
> -	self->buff_ring = (struct aq_ring_buff_s *)
> +	self->buff_ring =
>  		kzalloc(sizeof(struct aq_ring_buff_s) * self->size, GFP_KERNEL);

This should likely be kcalloc 
