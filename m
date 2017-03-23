From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute2 net-next 3/3] ip netconf: Show all families on dev
 request
Date: Thu, 23 Mar 2017 17:04:39 +0100
Message-ID: <3b0fef7e-262b-985d-de6d-2a7ddd4ff462@6wind.com>
References: <1490219962-32587-1-git-send-email-dsa@cumulusnetworks.com>
 <1490219962-32587-4-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:35017 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754542AbdCWQEs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 12:04:48 -0400
Received: by mail-wr0-f181.google.com with SMTP id u1so16597318wra.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:04:47 -0700 (PDT)
In-Reply-To: <1490219962-32587-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/03/2017 à 22:59, David Ahern a écrit :
> Currently specifying a device to ip netconf and it dumps only values
> for IPv4. Change this to dump data for all families unless a specific
> family is given.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  ip/ipnetconf.c | 23 +++++++++++++----------
>  1 file changed, 13 insertions(+), 10 deletions(-)
> 
> diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
> index dc0851025223..ab4c1d9db7c8 100644
> --- a/ip/ipnetconf.c
> +++ b/ip/ipnetconf.c
> @@ -56,6 +56,7 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
>  	struct netconfmsg *ncm = NLMSG_DATA(n);
>  	int len = n->nlmsg_len;
>  	struct rtattr *tb[NETCONFA_MAX+1];
> +	int ifindex = 0;
>  
>  	if (n->nlmsg_type == NLMSG_ERROR)
>  		return -1;
> @@ -77,6 +78,12 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
>  	parse_rtattr(tb, NETCONFA_MAX, netconf_rta(ncm),
>  		     NLMSG_PAYLOAD(n, sizeof(*ncm)));
>  
> +	if (tb[NETCONFA_IFINDEX])
> +		ifindex = *((int *)rta_getattr_str(tb[NETCONFA_IFINDEX]));
This line is moved, but rta_getattr_u32() is probably more right.


Regards,
Nicolas
