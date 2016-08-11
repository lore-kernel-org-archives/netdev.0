From: Edward Cree <ecree@solarflare.com>
Subject: Re: [iproute PATCH] ip-route: Pretty-print expired routes
Date: Thu, 11 Aug 2016 14:46:26 +0100
Message-ID: <9d2afc01-bb48-25f7-9cad-7c4926622a38@solarflare.com>
References: <1470827690-5625-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:65141 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932162AbcHKNqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:46:39 -0400
In-Reply-To: <1470827690-5625-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/16 12:14, Phil Sutter wrote:
> Instead of printing 'expires -23sec' for expired (but not yet garbage
> collected) routes, print 'expired 23sec' instead.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/iproute.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index c52294d298210..a89a26d68be0f 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -305,6 +305,14 @@ static void print_rtax_features(FILE *fp, unsigned int features)
>  		fprintf(fp, " 0x%x", of);
>  }
>  
> +static void print_expires(FILE *fp, __s32 expires, int hz)
> +{
> +	if (expires > 0)
> +		fprintf(fp, " expires %dsec", expires/hz);
> +	else
> +		fprintf(fp, " expired %dsec", -expires/hz);
> +}
Perhaps something that differs by more than a single character, to
make it stand out more?  I don't know what to suggest, though.

-Ed
