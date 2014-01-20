From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add support for physically
 discontinuous receive buffer
Date: Mon, 20 Jan 2014 22:10:40 +0000
Message-ID: <18b9150b090043b7b296593af994f8ee@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1389306287-20057-1-git-send-email-haiyangz@microsoft.com>
 <20140114.143133.1863157816134006560.davem@davemloft.net>
 <5f60b6bd1ea84eadbb730c7ea9d3d4d5@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>, David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <5f60b6bd1ea84eadbb730c7ea9d3d4d5@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Haiyang Zhang
> Sent: Monday, January 20, 2014 2:06 PM
> To: David Miller
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: RE: [PATCH net-next] hyperv: Add support for physically discontinuous
> receive buffer
> 
> 
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, January 14, 2014 5:32 PM
> > To: Haiyang Zhang
> > Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> > jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> > devel@linuxdriverproject.org
> > Subject: Re: [PATCH net-next] hyperv: Add support for physically discontinuous
> > receive buffer
> >
> > From: Haiyang Zhang <haiyangz@microsoft.com>
> > Date: Thu,  9 Jan 2014 14:24:47 -0800
> >
> > > This will allow us to use bigger receive buffer, and prevent
> > > allocation failure due to fragmented memory.
> > >
> > > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> >
> > Not until you start using paged SKBs in netvsc_recv_callback.
> >
> > Whatever fragmention you think you're avoiding in the hyperv layer, you're still
> > going to get from the:
> >
> > skb = netdev_alloc_skb_ip_align(net, packet->total_data_buflen);
> >
> > call there.
> >
> > This change makes no sense in isolation, therefore I'm not applying it until you
> > also include the appropriate changes to avoid the same exact fragmentation
> > issue in netvsc_drv.c as stated above.
> 
> The receive buffer currently requires multiple MB of physically continuous
> memory,
> and may fail to be allocated when memory is fragmented. The patch is created
> for
> this issue.
> 
> The SKB buffer is usually less than 1500 bytes or up to several KB with jumbo
> frame,
> so it's much less sensitive to fragmented memory. I will work on another patch to
> use
> SKB buffer with discontinuous pages.
> 
> Could you accept this patch separately?

Today, if we try to unload and load the network driver, the load may fail because we may 
not be able to allocate the receive buffers if memory is fragmented. This patch specifically addresses
this problem.

Regards,

K. Y
> 
> Thanks,
> - Haiyang
> 
