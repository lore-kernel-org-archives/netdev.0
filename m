From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/4 -rev1] Add new timeval_to_sec function
Date: Thu, 26 Jul 2007 07:58:22 +0200
Message-ID: <46A837FE.5060900@cosmosbay.com>
References: <20070726104526.0348e746.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42497 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbXGZF7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 01:59:16 -0400
In-Reply-To: <20070726104526.0348e746.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan a =E9crit :
> A new function for converting timeval to time_t is added in time.h. I=
ts a common function used in different
> places. The timeout is now rounded up as per the suggestion.
>=20
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> ---
>  include/linux/time.h |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/time.h b/include/linux/time.h
> index dda9be6..908329a 100644
> --- a/include/linux/time.h
> +++ b/include/linux/time.h
> @@ -147,6 +147,17 @@ static inline s64 timeval_to_ns(const st
>  }
> =20
>  /**
> + * timeval_to_sec - Convert timeval to seconds
> + * @tv:         pointer to the timeval variable to be converted
> + *
> + * Returns the seconds representation of timeval parameter.
> + */
> +static inline time_t timeval_to_sec(const struct timeval *tv)
> +{
> +	return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
> +}
> +
> +/**

return tv->tv_sec + (tv->tv_usec ? 1 : 0);

is much faster

Also, the comment is not accurate, as it doesnt mention the roundup at =
all.

