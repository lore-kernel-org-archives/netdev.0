From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: disallow ip rule del without parameters
Date: Mon, 29 Aug 2016 10:53:25 -0700
Message-ID: <20160829105325.40230e41@xeon-e3>
References: <20160824204252.2melotzdx6ftzgaq@ppc.Dlink>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35483 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755524AbcH2RxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:53:14 -0400
Received: by mail-pf0-f169.google.com with SMTP id x72so54300204pfd.2
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:53:14 -0700 (PDT)
In-Reply-To: <20160824204252.2melotzdx6ftzgaq@ppc.Dlink>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Aug 2016 23:43:00 +0300
"Andrey Jr. Melnikov" <temnota.am@gmail.com> wrote:

> Disallow run `ip rule del` without any parameter to avoid delete any first
> rule from table.
> 
> Signed-off-by: Andrey Jr. Melnikov <temnota.am@gmail.com>
> ---
> 
> diff --git a/ip/iprule.c b/ip/iprule.c
> index 8f24206..70562c5 100644
> --- a/ip/iprule.c
> +++ b/ip/iprule.c
> @@ -346,6 +346,11 @@ static int iprule_modify(int cmd, int argc, char **argv)
>  		req.r.rtm_type = RTN_UNICAST;
>  	}
>  
> +	if (cmd == RTM_DELRULE && argc == 0) {
> +		fprintf(stderr, "\"ip rule del\" requires arguments.\n");
> +		return -1;
> +	}
> +
>  	while (argc > 0) {
>  		if (strcmp(*argv, "not") == 0) {
>  			req.r.rtm_flags |= FIB_RULE_INVERT;


Actually ip rule delete without arguments deletes all rules.
Which could be a bug or feature depending on the user.
I can imagine somebody is doing something like deleting all rules
and putting in new ones for PBR.
