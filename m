From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 1/3] iproute2: add support for setting device groups
Date: Wed, 02 Feb 2011 09:56:28 +0100
Message-ID: <4D491C3C.2010805@trash.net>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org> <1296060086-18777-2-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63410 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab1BBI4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 03:56:42 -0500
In-Reply-To: <1296060086-18777-2-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.01.2011 17:41, Vlad Dogaru wrote:
> Use the group keyword to specify what group the device should belong to.
> Since the kernel uses numbers internally, mapping of group names to
> numbers is defined in /etc/iproute2/group_map. Example usage:
> 
>   ip link set dev eth0 group default
> 
> @@ -297,6 +299,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>  			if (get_integer(&mtu, *argv, 0))
>  				invarg("Invalid \"mtu\" value\n", *argv);
>  			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
> +		} else if (strcmp(*argv, "group") == 0) {
> +			NEXT_ARG();
> +			if (group != -1)
> +				duparg("group", *argv);
> +			if (lookup_map_id(*argv, &group, GROUP_MAP))
> +				invarg("Invalid \"group\" value\n", *argv);
> +			addattr_l(&req->n, sizeof(*req), IFLA_GROUP, &group, 4);

I think it would be preferrable to use a function similar to
rt_realm_n2a() that can also handle plain numerical values.
