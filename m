From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RESEND][PATCH 2/4 Rev-3] Add new timeval_to_sec function
Date: Wed, 19 Sep 2007 08:29:24 -0700
Message-ID: <20070919082924.14ca2c1b@freepuppy.rosehill.hemminger.net>
References: <20070919092407.ecd87071.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, krkumar2@in.ibm.com, tgraf@suug.ch,
	varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33904 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978AbXISPaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:30:19 -0400
In-Reply-To: <20070919092407.ecd87071.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 09:24:07 +0530
Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:

> A new function for converting timeval to time_t is added in netlink.h. Its a common function used in differentplaces. The reason for adding this function in netlink.h is that its used by netlink for stats purpose.
> 
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> ---
>  include/net/netlink.h |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/netlink.h b/include/net/netlink.h
> index d7b824b..f86cc59 100644
> --- a/include/net/netlink.h
> +++ b/include/net/netlink.h
> @@ -1100,4 +1100,17 @@ static inline int nla_validate_nested(st
>  #define nla_for_each_nested(pos, nla, rem) \
>  	nla_for_each_attr(pos, nla_data(nla), nla_len(nla), rem)
>  
> +/**
> + * timeval_to_sec - Convert timeval to seconds
> + * @tv:         pointer to the timeval variable to be converted
> + *
> + * Returns the seconds representation of timeval parameter.
> + * Note : Here we round up the value. We dont need accuracy.
> + * This is mainly used in netlink for stats purpose.
> + */
> +static inline time_t timeval_to_sec(const struct timeval *tv)
> +{
> +	return (tv->tv_sec + (tv->tv_usec ? 1 : 0));
> +}
> +
>  #endif

1. If needed it belongs in include/linux/time.h

2. You never adequately explained why the function rounds up? No other
   statistical or time interface does rounding, why should this API round
   and others do not?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
