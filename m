From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] include/uapi/linux/xfrm.h: Pack struct
 xfrm_usersa_info
Date: Wed, 8 Jan 2014 20:33:03 +0000
Message-ID: <1389213183.1644.31.camel@bwh-desktop.uk.level5networks.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
	 <1389077339-12814-3-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <dev@lists.strongswan.org>,
	<netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17093 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382AbaAHUdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:33:08 -0500
In-Reply-To: <1389077339-12814-3-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 14:48 +0800, Fan Du wrote:
> Otherwise 64bits kernel has sizeof(struct xfrm_usersa_info) 224 bytes,
> while 32bits compiled iproute2 see the same structure as 220 bytes, which
> leading deficit xfrm sa, in turn broken IPsec connectivity.
>
> Fix this by packing the structure.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  include/uapi/linux/xfrm.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> index 470bfae..61460c4 100644
> --- a/include/uapi/linux/xfrm.h
> +++ b/include/uapi/linux/xfrm.h
> @@ -366,7 +366,7 @@ struct xfrm_usersa_info {
>  #define XFRM_STATE_AF_UNSPEC	32
>  #define XFRM_STATE_ALIGN4	64
>  #define XFRM_STATE_ESN		128
> -};
> +} __attribute__((packed));
>  
>  #define XFRM_SA_XFLAG_DONT_ENCAP_DSCP	1
>  

That change will make access to the structure very slow on some
architectures, and I suspect it will cause other compatibility problems.

I think the right thing to do is to reduce the minimum length of the
structure in the netlink policy so that padding at the end is not
required.  (It looks like all field offsets will be the same on all
32/64-bit architecture pairs and there is only a differing amount of
padding at the end of the structure for 32/64-bit alignment.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
