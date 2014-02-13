From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net,v2] hyperv: Fix the carrier status setting
Date: Thu, 13 Feb 2014 00:05:01 +0000
Message-ID: <e1477cb2b75445248dcb9e31c0360eca@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1392056129-29398-1-git-send-email-haiyangz@microsoft.com>
 <52F9F293.7080601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <52F9F293.7080601@redhat.com>
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
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Tuesday, February 11, 2014 4:51 AM
> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
> Cc: KY Srinivasan; olaf@aepfle.de; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net,v2] hyperv: Fix the carrier status setting
> 
> On 02/11/2014 02:15 AM, Haiyang Zhang wrote:
> > Without this patch, the "cat /sys/class/net/ethN/operstate" shows
> > "unknown", and "ethtool ethN" shows "Link detected: yes", when VM
> > boots up with or without vNIC connected.
> >
> > This patch fixed the problem.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/net/hyperv/netvsc_drv.c |   24 +++++++++++++++---------
> >  1 files changed, 15 insertions(+), 9 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > b/drivers/net/hyperv/netvsc_drv.c index 7756118..18916f7 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -88,8 +88,12 @@ static int netvsc_open(struct net_device *net)  {
> >  	struct net_device_context *net_device_ctx = netdev_priv(net);
> >  	struct hv_device *device_obj = net_device_ctx->device_ctx;
> > +	struct netvsc_device *nvdev;
> > +	struct rndis_device *rdev;
> >  	int ret = 0;
> >
> > +	netif_carrier_off(net);
> > +
> >  	/* Open up the device */
> >  	ret = rndis_filter_open(device_obj);
> >  	if (ret != 0) {
> > @@ -99,6 +103,11 @@ static int netvsc_open(struct net_device *net)
> >
> >  	netif_start_queue(net);
> >
> > +	nvdev = hv_get_drvdata(device_obj);
> > +	rdev = nvdev->extension;
> > +	if (!rdev->link_state)
> 
> What if the link status interrupt comes here at this time?

Thank you for pointing this out. I have submitted an updated patch.
- Haiyang
