From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] utils: also check AF_INET family when rtm_type
 is RTN_MULTICAST
Date: Thu, 27 Jul 2017 11:11:20 +0200
Message-ID: <20170727091120.GO2235@orbyte.nwl.cc>
References: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37389 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750965AbdG0JLW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 05:11:22 -0400
Content-Disposition: inline
In-Reply-To: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hangbin,

On Thu, Jul 27, 2017 at 05:01:49PM +0800, Hangbin Liu wrote:
[...]
> diff --git a/lib/utils.c b/lib/utils.c
> index e77bd30..0479e00 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -1215,5 +1215,6 @@ int get_real_family(int rtm_type, int rtm_family)
>  	if (rtm_type != RTN_MULTICAST)
>  		return rtm_family;
>  
> -	return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
> +	return (rtm_family == RTNL_FAMILY_IPMR ||
> +		rtm_family == AF_INET) ? AF_INET : AF_INET6;
>  }

I think this is not very readable. How about this instead:

-       return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+       if (rtm_family == RTNL_FAMILY_IPMR)
+               return AF_INET;
+
+       return rtm_family;

Thanks, Phil
