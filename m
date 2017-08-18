From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 1/7] ipntable: Make sure filter.name is
 NULL-terminated
Date: Fri, 18 Aug 2017 09:19:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005A7B4@AcuExch.aculab.com>
References: <20170817170932.24659-1-phil@nwl.cc>
 <20170817170932.24659-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:62706 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751552AbdHRJTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 05:19:22 -0400
In-Reply-To: <20170817170932.24659-2-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 17 August 2017 18:09
> To: Stephen Hemminger
> Cc: netdev@vger.kernel.org
> Subject: [iproute PATCH v2 1/7] ipntable: Make sure filter.name is NULL-terminated
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipntable.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/ipntable.c b/ip/ipntable.c
> index 879626ee4f491..7be1f04d33d90 100644
> --- a/ip/ipntable.c
> +++ b/ip/ipntable.c
> @@ -633,7 +633,8 @@ static int ipntable_show(int argc, char **argv)
>  		} else if (strcmp(*argv, "name") == 0) {
>  			NEXT_ARG();
> 
> -			strncpy(filter.name, *argv, sizeof(filter.name));
> +			strncpy(filter.name, *argv, sizeof(filter.name) - 1);
> +			filter.name[sizeof(filter.name) - 1] = '\0';

Why not check for overflow instead?
			if (filter.name[sizeof(filter.name) - 1])
				usage("filer name too long");

	David
