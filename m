From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 12:49:25 -0700
Message-ID: <20170502124925.5276665e@xeon-e3>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
        <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35118 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdEBTt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:49:28 -0400
Received: by mail-pg0-f50.google.com with SMTP id o3so61137790pgn.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 12:49:28 -0700 (PDT)
In-Reply-To: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not disagreeing that iproute2 should handle the extended
error format. Just want the solution to be as small as possible;
ie do no more than is absolutely necessary. And future proof
for the inevitable growth in new area.

> +
> +static const __u8 nla_attr_minlen[NLA_TYPE_MAX+1] = {
> +	[NLA_U8]	= sizeof(__u8),
> +	[NLA_U16]	= sizeof(__u16),
> +	[NLA_U32]	= sizeof(__u32),
> +	[NLA_U64]	= sizeof(__u64),
> +	[NLA_MSECS]	= sizeof(__u64),
> +	[NLA_NESTED]	= NLA_HDRLEN,
> +	[NLA_S8]	= sizeof(__s8),
> +	[NLA_S16]	= sizeof(__s16),
> +	[NLA_S32]	= sizeof(__s32),
> +	[NLA_S64]	= sizeof(__s64),
> +};
> +

This patch makes iproute2 now doing validation of netlink attributes
coming back from the kernel. What is the point, userspace should be
trusting the kernel.
