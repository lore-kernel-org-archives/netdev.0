From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 23/42] mlxsw: spectrum_router: Implement fib4
 add/del switchdev obj ops
Date: Sat, 2 Jul 2016 08:30:10 +0200
Message-ID: <20160702063010.GA1995@nanopsycho.orion>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-24-git-send-email-jiri@resnulli.us>
 <070108fc-a6bd-b23e-8ada-ef82717a82ff@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, andy@greyhouse.net, tgraf@suug.ch,
	jhs@mojatatu.com, linville@tuxdriver.com, ivecera@redhat.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34824 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcGBGaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 02:30:13 -0400
Received: by mail-wm0-f68.google.com with SMTP id a66so9679151wme.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 23:30:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <070108fc-a6bd-b23e-8ada-ef82717a82ff@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 01, 2016 at 06:10:58PM CEST, dsa@cumulusnetworks.com wrote:
>On 7/1/16 8:04 AM, Jiri Pirko wrote:
>
>>+static int
>>+mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
>>+				const struct switchdev_obj_ipv4_fib *fib4,
>>+				struct mlxsw_sp_fib_entry *fib_entry)
>>+{
>>+	struct fib_info *fi = fib4->fi;
>>+
>>+	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
>>+		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
>>+		return 0;
>>+	}
>>+	if (fib4->type != RTN_UNICAST)
>>+		return -EINVAL;
>
>This is going to cause offload to fail b/c is a user has RTN_UNREACHABLE or
>RTN_PROHIBIT default route in a table. Those routes are needed per VRF/table
>to keep lookups from dropping to the another table.

We plan to support vfr offload as a follow-up

>
>
