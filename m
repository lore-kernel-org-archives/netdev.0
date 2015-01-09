From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] bonding: cleanup bond_opts array
Date: Fri, 9 Jan 2015 13:48:21 -0500
Message-ID: <20150109184821.GC56806@gospo.home.greyhouse.net>
References: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:44941 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbAISs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:48:27 -0500
Received: by mail-qc0-f175.google.com with SMTP id p6so10500540qcv.6
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:48:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 01:31:08PM -0500, Jonathan Toppins wrote:
> Remove the empty array element initializer and size the array with
> BOND_OPT_LAST so the compiler will complain if more elements are in
> there than should be.
> 
> An interesting unwanted side effect of this initializer is that if one
> inserts new options into the middle of the array then this initializer
> will zero out the option that equals BOND_OPT_TLB_DYNAMIC_LB+1.
> 
> Example:
> Extend the OPTS enum:
> enum {
>    ...
>    BOND_OPT_TLB_DYNAMIC_LB,
>    BOND_OPT_LACP_NEW1,
>    BOND_OPT_LAST
> };
> 
> Now insert into bond_opts array:
> static const struct bond_option bond_opts[] = {
>       ...
>       [BOND_OPT_LACP_RATE] = { .... unchanged stuff .... },
>       [BOND_OPT_LACP_NEW1] = { ... new stuff ... },
>       ...
>       [BOND_OPT_TLB_DYNAMIC_LB] = { .... unchanged stuff ....},
>       { } // MARK A
> };
> 
> Since BOND_OPT_LACP_NEW1 = BOND_OPT_TLB_DYNAMIC_LB+1, the last
> initializer (MARK A) will overwrite the contents of BOND_OPT_LACP_NEW1
> and can be easily viewed with the crash utility.
> 
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Cc: Nikolay Aleksandrov <nikolay@redhat.com>

I do not recall if there was a specific reason that Nik added this, so
presuming there was not....

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_options.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index 1a61cc9..9bd538d4 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -186,7 +186,7 @@ static const struct bond_opt_value bond_tlb_dynamic_lb_tbl[] = {
>  	{ NULL,  -1, 0}
>  };
>  
> -static const struct bond_option bond_opts[] = {
> +static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>  	[BOND_OPT_MODE] = {
>  		.id = BOND_OPT_MODE,
>  		.name = "mode",
> @@ -379,8 +379,7 @@ static const struct bond_option bond_opts[] = {
>  		.values = bond_tlb_dynamic_lb_tbl,
>  		.flags = BOND_OPTFLAG_IFDOWN,
>  		.set = bond_option_tlb_dynamic_lb_set,
> -	},
> -	{ }
> +	}
>  };
>  
>  /* Searches for an option by name */
> -- 
> 1.7.10.4
> 
