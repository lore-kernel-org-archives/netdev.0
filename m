From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] libnetlink: Double the dump buffer size
Date: Fri, 4 Mar 2016 15:35:53 -0800
Message-ID: <20160304153553.47e8741d@xeon-e3>
References: <8e235f49b8314d70bbf76709a81c4d84@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34862 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760453AbcCDXfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:35:46 -0500
In-Reply-To: <8e235f49b8314d70bbf76709a81c4d84@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Mar 2016 18:57:28 +0000
Phil Sutter <phil@nwl.cc> wrote:

> There have been reports about 'ip addr' printing "Message truncated" on
> systems with large numbers of VFs. Although I haven't been able to get
> my hands on hardware suitable to reproduce this, increasing the dump
> buffer has been reported to resolve the issue. For want of a better
> idea, just double the buffer size to 32k.
> 
> Feels like this opportunistic buffer size selection is rather
> workarounding a design flaw in libnetlink or maybe even the netlink
> protocol itself.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/libnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index d6b5fd3e8a493..245c4ca216753 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -223,7 +223,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>  		.msg_iov = &iov,
>  		.msg_iovlen = 1,
>  	};
> -	char buf[16384];
> +	char buf[32768];
>  	int dump_intr = 0;
>  
>  	iov.iov_base = buf;

I thought this was addressed in kernel by making the VF info optional.
The netlink protocol is showing some strain, this is one of them.
