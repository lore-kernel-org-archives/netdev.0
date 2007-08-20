From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/4 - rev2] Add new timeval_to_sec function
Date: Mon, 20 Aug 2007 07:53:25 -0700
Message-ID: <20070820075325.43bd8f60@freepuppy.rosehill.hemminger.net>
References: <20070820134536.d260585a.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60851 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502AbXHTOyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 10:54:12 -0400
In-Reply-To: <20070820134536.d260585a.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2007 13:45:36 +0530
Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:

> A new function for converting timeval to time_t is added in time.h. Its a common function used in different
> places.
> 
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> ---
>  include/linux/time.h |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/time.h b/include/linux/time.h
> index 6a5f503..1faf65c 100644
> --- a/include/linux/time.h
> +++ b/include/linux/time.h
> @@ -149,6 +149,18 @@ static inline s64 timeval_to_ns(const st
>  }
>  
>  /**
> + * timeval_to_sec - Convert timeval to seconds
> + * @tv:         pointer to the timeval variable to be converted
> + *
> + * Returns the seconds representation of timeval parameter.
> + * Note : Here we round up the value. We dont need accuracy.
> + */
> +static inline time_t timeval_to_sec(const struct timeval *tv)
> +{
> +	return (tv->tv_sec + (tv->tv_usec ? 1 : 0));
> +}
> +

Why roundup? Unless there is a requirement in the standard, please just
use the timeval seconds. In which case the inline is unneeded.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
