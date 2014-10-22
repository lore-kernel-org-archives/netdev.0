From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: dsa: Error out on tagging protocol mismatches
Date: Wed, 22 Oct 2014 16:46:52 -0700
Message-ID: <544841EC.4070103@gmail.com>
References: <1414020918-20903-1-git-send-email-andrew@lunn.ch> <1414020918-20903-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:47110 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbaJVXrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 19:47:13 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so212734pde.18
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 16:47:13 -0700 (PDT)
In-Reply-To: <1414020918-20903-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 04:35 PM, Andrew Lunn wrote:
> If there is a mismatch between enabled tagging protocols and the
> protocol the switch supports, error out, rather than continue with a
> situation which is unlikely to work.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> cc: alexander.h.duyck@intel.com
> ---
>  net/dsa/dsa.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 22f34cf4cb27..8a31bd81a315 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -175,7 +175,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  			break;
>  #endif
>  		default:
> -			break;
> +			ret = -ENOPROTOOPT;
> +			goto out;
>  		}

This prevents using a switch driver without tagging, which is something
that you might want to do (link setup, ethtool stats, EEE etc...).
--
Florian
