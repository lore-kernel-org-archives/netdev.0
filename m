From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCHv2 RFC] RTEXT_FILTER_SKIP_STATS support to avoid dumping
 inet/inet6 stats
Date: Sat, 12 Sep 2015 00:22:44 +0530
Message-ID: <55F322FC.1050509@linux.vnet.ibm.com>
References: <20150910213429.GH28585@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	jose.marchesi@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:48962 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbIKSvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 14:51:02 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Sat, 12 Sep 2015 00:20:59 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 120F0E0054
	for <netdev@vger.kernel.org>; Sat, 12 Sep 2015 00:20:23 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8BIos1O43516092
	for <netdev@vger.kernel.org>; Sat, 12 Sep 2015 00:20:55 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8BIosoZ020069
	for <netdev@vger.kernel.org>; Sat, 12 Sep 2015 00:20:54 +0530
In-Reply-To: <20150910213429.GH28585@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 03:04 AM, Sowmini Varadhan wrote:
>
> Many commonly used functions like getifaddrs() invoke RTM_GETLINK
> to dump the interface information, and do not need the
> the AF_INET6 statististics that are always returned by default
> from rtnl_fill_ifinfo().
>
> Computing the statistics can be an expensive operation that impacts
> scaling, so it is desirable to avoid this if the information is
> not needed.
>
> This patch adds a the RTEXT_FILTER_SKIP_STATS extended info flag that
> can be passed with netlink_request() to avoid statistics computation
> for the ifinfo path.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: David Miller comments: pass u32 ext_filter_mask down.
>
>   include/net/rtnetlink.h        |    3 ++-
>   include/uapi/linux/rtnetlink.h |    1 +
>   net/core/rtnetlink.c           |    2 +-
>   net/ipv4/devinet.c             |    3 ++-
>   net/ipv6/addrconf.c            |   13 +++++++++----
>   5 files changed, 15 insertions(+), 7 deletions(-)

Sowmini, Thanks for the patch which is more cleaner way without
breaking current behaviour.

[ Though RTEXT_FILTER_NEED_STATS flag with reverse effect  would have
helped immediately :)]

/me waits for the RTEXT_FILTER_SKIP_STATS to be supported in
gccgo/golang, so that it can be used in docker newNetlinkRequest() to
exploit this.
