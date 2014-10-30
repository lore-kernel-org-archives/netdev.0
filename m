From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip link: Allow to filter devices by master dev
Date: Thu, 30 Oct 2014 10:54:29 +0200
Message-ID: <20141030085429.GA22884@angus-think.wlc.globallogic.com>
References: <1413727488-18032-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:64572 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758242AbaJ3JDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 05:03:48 -0400
Received: by mail-wi0-f176.google.com with SMTP id h11so3856223wiw.9
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 02:03:47 -0700 (PDT)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id bv17sm21468400wib.13.2014.10.30.02.03.45
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 02:03:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413727488-18032-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 05:04:48PM +0300, Vadim Kochan wrote:
> Added 'master' option to 'ip link show' command
> to filter devices by master dev.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  ip/ipaddress.c        | 16 ++++++++++++++++
>  ip/iplink.c           |  2 +-
>  man/man8/ip-link.8.in |  9 ++++++++-
>  3 files changed, 25 insertions(+), 2 deletions(-)
> 
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 45729d8..8a0e2ab 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -56,6 +56,7 @@ static struct
>  	int flushp;
>  	int flushe;
>  	int group;
> +	int master;
>  } filter;
>  
>  static int do_link;
> @@ -480,6 +481,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>  			return -1;
>  	}
>  
> +	if (tb[IFLA_MASTER]) {
> +		int master = *(int*)RTA_DATA(tb[IFLA_MASTER]);
> +		if (filter.master > 0 && master != filter.master)
> +			return -1;
> +	}
> +	else if (filter.master > 0)
> +		return -1;
> +
>  	if (n->nlmsg_type == RTM_DELLINK)
>  		fprintf(fp, "Deleted ");
>  
> @@ -1215,6 +1224,13 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
>  			NEXT_ARG();
>  			if (rtnl_group_a2n(&filter.group, *argv))
>  				invarg("Invalid \"group\" value\n", *argv);
> +		} else if (strcmp(*argv, "master") == 0) {
> +			int ifindex;
> +			NEXT_ARG();
> +			ifindex = ll_name_to_index(*argv);
> +			if (!ifindex)
> +				invarg("Device does not exist\n", *argv);
> +			filter.master = ifindex;
>  		} else {
>  			if (strcmp(*argv, "dev") == 0) {
>  				NEXT_ARG();
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 43b26f4..ce6eb3e 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -82,7 +82,7 @@ void iplink_usage(void)
>  	fprintf(stderr, "			  [ master DEVICE ]\n");
>  	fprintf(stderr, "			  [ nomaster ]\n");
>  	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
> -	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
> +	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV]\n");
>  
>  	if (iplink_have_newlink()) {
>  		fprintf(stderr, "       ip link help [ TYPE ]\n");
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 383917a..279fe39 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -144,7 +144,9 @@ ip-link \- network device configuration
>  .B ip link show
>  .RI "[ " DEVICE " | "
>  .B group
> -.IR GROUP " ]"
> +.IR GROUP " | "
> +.B master
> +.IR DEVICE " ]"
>  
>  .SH "DESCRIPTION"
>  .SS ip link add - add virtual link
> @@ -658,6 +660,11 @@ specifies what group of devices to show.
>  .B up
>  only display running interfaces.
>  
> +.TP
> +.BI master " DEVICE "
> +.I DEVICE
> +specifies the master device which enslaves devices to show.
> +
>  .SH "EXAMPLES"
>  .PP
>  ip link show
> -- 
> 2.1.0
> 

Please reject this patch, I will send v2 because of conflicts with
'master' branch.

Regards,
