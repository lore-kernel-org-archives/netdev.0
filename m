From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix the carrier status setting
Date: Mon, 10 Feb 2014 15:57:55 +0000
Message-ID: <6fdabe9acd3d458c895746a049c6d066@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1391994478-25809-1-git-send-email-haiyangz@microsoft.com>
 <52F8D417.6020302@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F8D417.6020302@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Monday, February 10, 2014 8:29 AM
> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
> Cc: KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-
> kernel@vger.kernel.org; driverdev-devel@linuxdriverproject.org
> Subject: Re: [PATCH net] hyperv: Fix the carrier status setting
> 
> Hello.
> 
> On 10-02-2014 5:07, Haiyang Zhang wrote:
> 
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >   drivers/net/hyperv/netvsc_drv.c |   24 +++++++++++++++---------
> >   1 files changed, 15 insertions(+), 9 deletions(-)
> 
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > b/drivers/net/hyperv/netvsc_drv.c index 7756118..836211c 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> [...]
> > @@ -229,15 +238,17 @@ void netvsc_linkstatus_callback(struct hv_device
> *device_obj,
> >   	struct net_device *net;
> >   	struct net_device_context *ndev_ctx;
> >   	struct netvsc_device *net_device;
> > +	struct rndis_device *rdev;
> >
> >   	net_device = hv_get_drvdata(device_obj);
> > +	rdev = net_device->extension;
> > +
> > +	rdev->link_state = !(status == 1);
> 
>     Why not just 'status != 1'?

I will simplify it.
Thanks,
- Haiyang
