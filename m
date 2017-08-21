From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v3 4/5] tc/tc_filter: Make sure filter name is
 not empty
Date: Mon, 21 Aug 2017 14:53:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005CC54@AcuExch.aculab.com>
References: <20170821100308.24854-1-phil@nwl.cc>
 <20170821100308.24854-5-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:58955 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753412AbdHUOxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 10:53:53 -0400
In-Reply-To: <20170821100308.24854-5-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 21 August 2017 11:03
> To: Stephen Hemminger
> Cc: netdev@vger.kernel.org
> Subject: [iproute PATCH v3 4/5] tc/tc_filter: Make sure filter name is not empty
> 
> The later check for 'k[0] != 0' requires a non-empty filter name,
> otherwise NULL pointer dereference in 'q' might happen.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v2:
> - Instead of calling strlen(), just make sure **argv is not 0.
> ---
>  tc/tc_filter.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/tc/tc_filter.c b/tc/tc_filter.c
> index b13fb9185d4fd..cf290ae8e252c 100644
> --- a/tc/tc_filter.c
> +++ b/tc/tc_filter.c
> @@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
>  			usage();
>  			return 0;
>  		} else {
> +			if (!**argv)
> +				invarg("invalid filter name", *argv);
> +

The error message won't make sense...

	David
