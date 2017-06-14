From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip: mroute: Add table output to show command
Date: Wed, 14 Jun 2017 15:53:47 +0300
Message-ID: <eedea7e1-f2bc-d830-6da5-ec53e042845e@cumulusnetworks.com>
References: <1497442092-14252-1-git-send-email-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:34989 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbdFNMxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 08:53:51 -0400
Received: by mail-wr0-f173.google.com with SMTP id q97so188747137wrb.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 05:53:50 -0700 (PDT)
In-Reply-To: <1497442092-14252-1-git-send-email-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/06/17 15:08, Donald Sharp wrote:
> When the user specifies `table all` or `table 0` to
> the `ip mroute show` command we dump the entirety of
> the known mroute tables.  Without some sort of
> divisor to tell us what table we are looking at
> the command is useless.
> 
> Add `Table: <vrf name>` to the output of 'ip mroute show table 0'
> 
> Follow the convention established by 'ip route show table 0'
> for when to display
> 
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> ---
>  ip/ipmroute.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/ip/ipmroute.c b/ip/ipmroute.c
> index 4d2d758..70f4c4f 100644
> --- a/ip/ipmroute.c
> +++ b/ip/ipmroute.c
> @@ -189,6 +189,11 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  		fprintf(fp, ", Age %4i.%.2i", (int)tv.tv_sec,
>  			(int)tv.tv_usec/10000);
>  	}
> +
> +	if (table && (table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
> +		fprintf(fp, " Table: %s",
> +			rtnl_rttable_n2a(table, b1, sizeof(b1)));
> +
>  	fprintf(fp, "\n");
>  	fflush(fp);
>  	return 0;
> 

LGTM, thanks!

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
