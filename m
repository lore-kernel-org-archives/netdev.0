From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] net: dsa: Error out on tagging protocol mismatches
Date: Fri, 24 Oct 2014 15:42:24 -0700
Message-ID: <544AD5D0.4070908@gmail.com>
References: <1414187045-8326-1-git-send-email-andrew@lunn.ch> <1414187045-8326-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:49149 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbaJXWmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:42:47 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so2195823pdj.24
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:42:47 -0700 (PDT)
In-Reply-To: <1414187045-8326-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2014 02:44 PM, Andrew Lunn wrote:
> If there is a mismatch between enabled tagging protocols and the
> protocol the switch supports, error out, rather than continue with a
> situation which is unlikely to work.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> cc: alexander.h.duyck@intel.com
> ---
> 
> v2: Handle the use case of DSA_TAG_PROTO_NONE
> 
>  net/dsa/dsa.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 22f34cf4cb27..6317b41c99b0 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -174,8 +174,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  			dst->rcv = brcm_netdev_ops.rcv;
>  			break;
>  #endif
> -		default:
> +		case DSA_TAG_PROTO_NONE:
>  			break;
> +		default:
> +			ret = -ENOPROTOOPT;
> +			goto out;
>  		}
>  
>  		dst->tag_protocol = drv->tag_protocol;
> 
