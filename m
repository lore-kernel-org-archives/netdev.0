From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sun, 21 Jun 2015 19:05:03 -0700
Message-ID: <55876D4F.9030204@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <B5595950-0AF1-4141-A7FA-2C0CB11950D3@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33930 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbbFVCFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 22:05:06 -0400
Received: by pdbki1 with SMTP id ki1so128163241pdb.1
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 19:05:06 -0700 (PDT)
In-Reply-To: <B5595950-0AF1-4141-A7FA-2C0CB11950D3@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/15, 9:38 AM, Nikolay Aleksandrov wrote:
> <<<snip>>>
>> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
>> new file mode 100644
>> index 0000000..29c7802
>> --- /dev/null
>> +++ b/net/core/lwtunnel.c
>> @@ -0,0 +1,162 @@
>> +/*
>> + * lwtunnel	Infrastructure for light weight tunnels like mpls
>> + *
>> + *
>> + *		This program is free software; you can redistribute it and/or
>> + *		modify it under the terms of the GNU General Public License
>> + *		as published by the Free Software Foundation; either version
>> + *		2 of the License, or (at your option) any later version.
>> + *
>> + */
>> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> +
>> +#include <linux/capability.h>
>> +#include <linux/module.h>
>> +#include <linux/types.h>
>> +#include <linux/kernel.h>
>> +#include <linux/slab.h>
>> +#include <linux/uaccess.h>
>> +#include <linux/skbuff.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/in.h>
>> +#include <linux/init.h>
>> +#include <linux/err.h>
>> +
>> +#include <net/lwtunnel.h>
>> +#include <net/rtnetlink.h>
>> +
>> +struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
>> +{
>> +	struct lwtunnel_state *lws;
>> +
>> +	return kzalloc(sizeof(*lws) + hdr_len, GFP_KERNEL);
> This seems to be called with rcu_read_lock so GFP_ATOMIC  would have =
to
> be used. (Judging by patch 3/3=E2=80=99s mpls_build_state and lwtunne=
l_build_state)
>
yep, correct. thanks
