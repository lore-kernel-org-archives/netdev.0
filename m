From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 23/42] mlxsw: spectrum_router: Implement fib4
 add/del switchdev obj ops
Date: Fri, 1 Jul 2016 10:10:58 -0600
Message-ID: <070108fc-a6bd-b23e-8ada-ef82717a82ff@cumulusnetworks.com>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-24-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	tgraf@suug.ch, jhs@mojatatu.com, linville@tuxdriver.com,
	ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35710 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcGAQLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 12:11:01 -0400
Received: by mail-io0-f180.google.com with SMTP id f30so104167989ioj.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 09:11:00 -0700 (PDT)
In-Reply-To: <1467381910-3445-24-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/16 8:04 AM, Jiri Pirko wrote:

> +static int
> +mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
> +				const struct switchdev_obj_ipv4_fib *fib4,
> +				struct mlxsw_sp_fib_entry *fib_entry)
> +{
> +	struct fib_info *fi = fib4->fi;
> +
> +	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
> +		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
> +		return 0;
> +	}
> +	if (fib4->type != RTN_UNICAST)
> +		return -EINVAL;

This is going to cause offload to fail b/c is a user has RTN_UNREACHABLE 
or RTN_PROHIBIT default route in a table. Those routes are needed per 
VRF/table to keep lookups from dropping to the another table.
