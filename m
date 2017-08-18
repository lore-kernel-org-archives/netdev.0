From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 4/5] tc/tc_filter: Make sure filter name is
 not empty
Date: Fri, 18 Aug 2017 09:30:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005A7E9@AcuExch.aculab.com>
References: <20170817170931.24545-1-phil@nwl.cc>
 <20170817170931.24545-5-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:62017 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdHRJak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 05:30:40 -0400
In-Reply-To: <20170817170931.24545-5-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 17 August 2017 18:10
> The later check for 'k[0] != 0' requires a non-empty filter name,
> otherwise NULL pointer dereference in 'q' might happen.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  tc/tc_filter.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/tc/tc_filter.c b/tc/tc_filter.c
> index b13fb9185d4fd..a799edb35886d 100644
> --- a/tc/tc_filter.c
> +++ b/tc/tc_filter.c
> @@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
>  			usage();
>  			return 0;
>  		} else {
> +			if (!strlen(*argv))
> +				invarg("invalid filter name", *argv);

That is nearly as bad as:
	p[strlen(p)] = 0;

> +
>  			strncpy(k, *argv, sizeof(k)-1);
> 
>  			q = get_filter_kind(k);
> --
> 2.13.1
