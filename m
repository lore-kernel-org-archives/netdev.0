From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] net/hyperv: RX packets may keep on increasing although
 the NIC is down
Date: Wed, 18 Apr 2012 14:10:44 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD331E1@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1334757694-21745-1-git-send-email-wenqi_ma@trendmicro.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	KY Srinivasan <kys@microsoft.com>
To: Wenqi Ma <wenqi_ma@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:20657
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751071Ab2DROKy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 10:10:54 -0400
In-Reply-To: <1334757694-21745-1-git-send-email-wenqi_ma@trendmicro.com.cn>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Wenqi Ma [mailto:wenqi_ma@trendmicro.com.cn]
> Sent: Wednesday, April 18, 2012 10:02 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Haiyang Zhang; Wenqi Ma
> Subject: [PATCH] net/hyperv: RX packets may keep on increasing although
> the NIC is down
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
> ---
>  drivers/net/hyperv/netvsc_drv.c |   32 +++++++++++++-------------------
>  1 files changed, 13 insertions(+), 19 deletions(-)

Thanks for patching it. I have some comments --
The existing "struct set_multicast_work" is no longer in use, so it should be removed now.
You should also add cancel_work into netvsc_change_mtu().

Thanks,
- Haiyang
