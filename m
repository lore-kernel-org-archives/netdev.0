From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add support for physically
 discontinuous receive buffer
Date: Mon, 20 Jan 2014 22:06:19 +0000
Message-ID: <5f60b6bd1ea84eadbb730c7ea9d3d4d5@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1389306287-20057-1-git-send-email-haiyangz@microsoft.com>
 <20140114.143133.1863157816134006560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.88]:56094 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbaATWH3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 17:07:29 -0500
In-Reply-To: <20140114.143133.1863157816134006560.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 14, 2014 5:32 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Add support for physically discontinuous
> receive buffer
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Thu,  9 Jan 2014 14:24:47 -0800
> 
> > This will allow us to use bigger receive buffer, and prevent
> > allocation failure due to fragmented memory.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Not until you start using paged SKBs in netvsc_recv_callback.
> 
> Whatever fragmention you think you're avoiding in the hyperv layer, you're still
> going to get from the:
> 
> 	skb = netdev_alloc_skb_ip_align(net, packet->total_data_buflen);
> 
> call there.
> 
> This change makes no sense in isolation, therefore I'm not applying it until you
> also include the appropriate changes to avoid the same exact fragmentation
> issue in netvsc_drv.c as stated above.

The receive buffer currently requires multiple MB of physically continuous memory,
and may fail to be allocated when memory is fragmented. The patch is created for
this issue.

The SKB buffer is usually less than 1500 bytes or up to several KB with jumbo frame, 
so it's much less sensitive to fragmented memory. I will work on another patch to use 
SKB buffer with discontinuous pages. 

Could you accept this patch separately?

Thanks,
- Haiyang
