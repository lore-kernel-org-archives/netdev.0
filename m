From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [IPROUTE PATCH] libnetlink: Use ifinfomsg instead of rtgenmsg
 in rtnl_wilddump_req_filter
Date: Thu, 2 May 2013 17:13:05 +0300
Message-ID: <51827471.7030802@mellanox.com>
References: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:45425 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759764Ab3EBONh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 10:13:37 -0400
In-Reply-To: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/04/2013 01:07, Alexander Duyck wrote:
> This change corrects a kernel incompatibility that was resulting in the
> ext_filter_mask not being correctly discovered by the kernel as it is buried
> somewhere in the ifinfomsg.

working well,  thanks for fixing this upAlex.

Or.

>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>   lib/libnetlink.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index 04201cd..b17e1aa 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -99,7 +99,7 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
>   {
>   	struct {
>   		struct nlmsghdr nlh;
> -		struct rtgenmsg g;
> +		struct ifinfomsg ifm;
>   		/* attribute has to be NLMSG aligned */
>   		struct rtattr ext_req __attribute__ ((aligned(NLMSG_ALIGNTO)));
>   		__u32 ext_filter_mask;
> @@ -111,7 +111,7 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
>   	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
>   	req.nlh.nlmsg_pid = 0;
>   	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
> -	req.g.rtgen_family = family;
> +	req.ifm.ifi_family = family;
>   
>   	req.ext_req.rta_type = IFLA_EXT_MASK;
>   	req.ext_req.rta_len = RTA_LENGTH(sizeof(__u32));
>
