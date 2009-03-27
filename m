From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE2][PATCH 2/2] Enable Type Labels For "ip monitor all"
Date: Fri, 27 Mar 2009 11:28:59 -0700
Message-ID: <20090327112859.1624a0ce@nehalam>
References: <20090312134243.1b15fc2c.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36820 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbZC0S3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 14:29:08 -0400
In-Reply-To: <20090312134243.1b15fc2c.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Mar 2009 13:42:43 +0530
Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:

> This patch adds prefix lables for "ip monitor all" command to simplfy
> understanding of the output.
> 
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> ---
>  ip/ipmonitor.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
> index a74730e..baf25a8 100644
> --- a/ip/ipmonitor.c
> +++ b/ip/ipmonitor.c
> @@ -25,6 +25,7 @@
>  #include "ip_common.h"
>  
>  static void usage(void) __attribute__((noreturn));
> +int prefix_banner;
>  
>  static void usage(void)
>  {
> @@ -42,31 +43,45 @@ int accept_msg(const struct sockaddr_nl *who,
>  		print_timestamp(fp);
>  
>  	if (n->nlmsg_type == RTM_NEWROUTE || n->nlmsg_type == RTM_DELROUTE) {
> +		if (prefix_banner)
> +			fprintf(fp, "[ROUTE]");
>  		print_route(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
>  		ll_remember_index(who, n, NULL);
> +		if (prefix_banner)
> +			fprintf(fp, "[LINK]");
>  		print_linkinfo(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
> +		if (prefix_banner)
> +			fprintf(fp, "[ADDR]");
>  		print_addrinfo(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
> +		if (prefix_banner)
> +			fprintf(fp, "[ADDRLABEL]");
>  		print_addrlabel(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH) {
> +		if (prefix_banner)
> +			fprintf(fp, "[NEIGH]");
>  		print_neigh(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWPREFIX) {
> +		if (prefix_banner)
> +			fprintf(fp, "[PREFIX]");
>  		print_prefix(who, n, arg);
>  		return 0;
>  	}
>  	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
> +		if (prefix_banner)
> +			fprintf(fp, "[RULE]");
>  		print_rule(who, n, arg);
>  		return 0;
>  	}
> @@ -130,6 +145,7 @@ int do_ipmonitor(int argc, char **argv)
>  			groups = 0;		
>  		} else if (strcmp(*argv, "all") == 0) {
>  			groups = ~RTMGRP_TC;
> +			prefix_banner=1;
>  		} else if (matches(*argv, "help") == 0) {
>  			usage();
>  		} else {

applied
