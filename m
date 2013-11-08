From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Fix iteration count in sff8472_calibration()
Date: Fri, 8 Nov 2013 16:54:58 +0000
Message-ID: <1383929698.3802.24.camel@bwh-desktop.uk.level5networks.com>
References: <1379813802.21174.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Aurelien Guillaume <aurelien@iwi.me>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17214 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757541Ab3KHQzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 11:55:01 -0500
In-Reply-To: <1379813802.21174.36.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-22 at 02:36 +0100, Ben Hutchings wrote:
> We want to iterate over all elements of the various arrays of readings
> (which all have the same dimensions - and maybe ought to be a single
> array).  Unfortunately the iteration count is sizeof(sd->bias_cur) and
> bias_cur has 2-byte elements, so we iterate over twice as many
> elements as are really there.
> 
> Compiler-detected, and compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---

Applied.  Thanks, me.

Ben.

>  sfpdiag.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/sfpdiag.c b/sfpdiag.c
> index f67e491..04fd880 100644
> --- a/sfpdiag.c
> +++ b/sfpdiag.c
> @@ -224,7 +224,7 @@ static void sff8472_calibration(const __u8 *id, struct sff8472_diags *sd)
>  	__u16 rx_reading;
>  
>  	/* Calibration should occur for all values (threshold and current) */
> -	for (i = 0; i < sizeof(sd->bias_cur); ++i) {
> +	for (i = 0; i < ARRAY_SIZE(sd->bias_cur); ++i) {
>  		/*
>  		 * Apply calibration formula 1 (Temp., Voltage, Bias, Tx Power)
>  		 */
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
