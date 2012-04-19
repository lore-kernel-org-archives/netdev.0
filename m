From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] net/hyperv: Adding cancellation to ensure rndis filter
 is closed
Date: Thu, 19 Apr 2012 15:18:41 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD33BA8@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1334831977-5553-1-git-send-email-wenqi_ma@trendmicro.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	KY Srinivasan <kys@microsoft.com>
To: Wenqi Ma <wenqi_ma@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:51645
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752277Ab2DSPWj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 11:22:39 -0400
In-Reply-To: <1334831977-5553-1-git-send-email-wenqi_ma@trendmicro.com.cn>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Wenqi Ma [mailto:wenqi_ma@trendmicro.com.cn]
> Sent: Thursday, April 19, 2012 6:40 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Haiyang Zhang; Wenqi Ma
> Subject: [PATCH] net/hyperv: Adding cancellation to ensure rndis filter is
> closed
> 
> Although the network interface is down, the RX packets number which
> could be observed by ifconfig may keep on increasing.
> 
> This is because the WORK scheduled in netvsc_set_multicast_list()
> may be executed after netvsc_close(). That means the rndis filter
> may be re-enabled by do_set_multicast() even if it was closed by
> netvsc_close().
> 
> By canceling possible WORK before close the rndis filter, the issue
> could be never happened.
> 
> Signed-off-by: Wenqi Ma <wenqi_ma@trendmicro.com.cn>
> Reviewed-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/hyperv/netvsc_drv.c |   38 ++++++++++++++--------------------
> ----
>  1 files changed, 14 insertions(+), 24 deletions(-)

Thank you for the patch.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
