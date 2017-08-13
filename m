From: David Ahern <dsahern@gmail.com>
Subject: Re: [iproute PATCH 06/51] iplink_vrf: Complain if main table is not
 found
Date: Sun, 13 Aug 2017 09:58:55 -0600
Message-ID: <cab9f83d-04a9-f676-d891-ee2cef5a1a7b@gmail.com>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-7-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33720 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdHMP65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 11:58:57 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so6847364pgb.0
        for <netdev@vger.kernel.org>; Sun, 13 Aug 2017 08:58:57 -0700 (PDT)
In-Reply-To: <20170812120510.28750-7-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/17 6:04 AM, Phil Sutter wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/iplink_vrf.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
> index 917630e853375..809eda5de8f6e 100644
> --- a/ip/iplink_vrf.c
> +++ b/ip/iplink_vrf.c
> @@ -131,7 +131,10 @@ __u32 ipvrf_get_table(const char *name)
>  					   &answer.n, sizeof(answer)) < 0) {
>  		/* special case "default" vrf to be the main table */
>  		if (errno == ENODEV && !strcmp(name, "default"))
> -			rtnl_rttable_a2n(&tb_id, "main");
> +			if (rtnl_rttable_a2n(&tb_id, "main"))
> +				fprintf(stderr,
> +					"BUG: RTTable \"main\" not found.\n");
> +
>  
>  		return tb_id;
>  	}
> 

Acked-by: David Ahern <dsahern@gmail.com>
