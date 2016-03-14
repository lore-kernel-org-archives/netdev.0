From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v4] bridge: mdb: add support for
 extended router port information
Date: Sun, 13 Mar 2016 23:37:08 -0700
Message-ID: <20160313233708.57005031@xeon-e3>
References: <1457343179-30053-1-git-send-email-nikolay@cumulusnetworks.com>
	<1457345432-19360-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37204 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbcCNGgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 02:36:55 -0400
Received: by mail-ig0-f181.google.com with SMTP id mh10so7153795igb.0
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 23:36:54 -0700 (PDT)
In-Reply-To: <1457345432-19360-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  7 Mar 2016 11:10:32 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

>  	rem = RTA_PAYLOAD(attr);
>  	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
>  		port_ifindex = RTA_DATA(i);
> -		fprintf(f, "%s ", ll_index_to_name(*port_ifindex));
> +		if (show_stats) {
> +			struct rtattr *tb[MDBA_ROUTER_PATTR_MAX + 1];
> +
> +			parse_rtattr(tb, MDBA_ROUTER_PATTR_MAX,
> +				     MDB_RTR_RTA(RTA_DATA(i)),
> +				     RTA_PAYLOAD(i) -
> +				     RTA_ALIGN(sizeof(*port_ifindex)));
> +
> +			fprintf(f, "router ports on %s: %s",
> +				ll_index_to_name(brifidx),
> +				ll_index_to_name(*port_ifindex));
> +			if (tb[MDBA_ROUTER_PATTR_TIMER]) {
> +				struct timeval tv;
> +				__u32 tval;
> +
> +				tval = rta_getattr_u32(
> +						tb[MDBA_ROUTER_PATTR_TIMER]);
> +				__jiffies_to_tv(&tv, tval);
> +				fprintf(f, " %4i.%.2i",
> +					(int)tv.tv_sec, (int)tv.tv_usec/10000);
> +			}

You are having to cut lines short here to fit 80 characters, maybe
good time to make statistics a helper function.
