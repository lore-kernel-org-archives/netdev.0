From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 2/5] iplink: bridge: add support for
 IFLA_BR_VLAN_STATS_ENABLED
Date: Tue, 17 Jan 2017 10:52:51 +0100
Message-ID: <8e9fea7a-ba8c-d587-5895-cb56c0bb4832@cumulusnetworks.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
 <1484645552-29440-3-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36378 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdAQJwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 04:52:54 -0500
Received: by mail-lf0-f43.google.com with SMTP id z134so98966744lff.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 01:52:53 -0800 (PST)
In-Reply-To: <1484645552-29440-3-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/17 10:32, Hangbin Liu wrote:
> This patch implements support for the IFLA_BR_VLAN_STATS_ENABLED
> attribute in iproute2 so it can change the vlan state.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---

Again it is not state, it is _stats_. Please change the name to something like vlan_stats_enabled which is closer to the netlink attribute.

>  ip/iplink_bridge.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
> index 85e6597..8caf53a 100644
> --- a/ip/iplink_bridge.c
> +++ b/ip/iplink_bridge.c
> @@ -34,6 +34,7 @@ static void print_explain(FILE *f)
>  		"                  [ vlan_filtering VLAN_FILTERING ]\n"
>  		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
>  		"                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]\n"
> +		"                  [ vlan_state VLAN_STATE ]\n"
>  		"                  [ mcast_snooping MULTICAST_SNOOPING ]\n"
>  		"                  [ mcast_router MULTICAST_ROUTER ]\n"
>  		"                  [ mcast_query_use_ifaddr MCAST_QUERY_USE_IFADDR ]\n"
> @@ -157,6 +158,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
>  
>  			addattr16(n, 1024, IFLA_BR_VLAN_DEFAULT_PVID,
>  				  default_pvid);
> +		} else if (matches(*argv, "vlan_state") == 0) {
> +			__u8 vlan_state;
> +
> +			NEXT_ARG();
> +			if (get_u8(&vlan_state, *argv, 0))
> +				invarg("invalid vlan_state", *argv);
> +			addattr8(n, 1024, IFLA_BR_VLAN_STATS_ENABLED,
> +				  vlan_state);
>  		} else if (matches(*argv, "mcast_router") == 0) {
>  			__u8 mcast_router;
>  
> @@ -442,6 +451,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  		fprintf(f, "vlan_default_pvid %u ",
>  			rta_getattr_u16(tb[IFLA_BR_VLAN_DEFAULT_PVID]));
>  
> +	if (tb[IFLA_BR_VLAN_STATS_ENABLED])
> +		fprintf(f, "vlan_state %u ",
> +			rta_getattr_u8(tb[IFLA_BR_VLAN_STATS_ENABLED]));
> +
>  	if (tb[IFLA_BR_GROUP_FWD_MASK])
>  		fprintf(f, "group_fwd_mask %#x ",
>  			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
> 
