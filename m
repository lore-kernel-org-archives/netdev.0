From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Thu, 8 May 2014 19:47:52 +0000
Message-ID: <ec503f90e3914e2786e0f0d0f7dc0796@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1399502704-18495-1-git-send-email-haiyangz@microsoft.com>
 <20140508091304.GB24820@kroah.com>
 <67b9b573b20f4cc2b6fe75fe84ee48e1@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140508190712.GB6766@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Greg KH <greg@kroah.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140508190712.GB6766@kroah.com>
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
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Thursday, May 8, 2014 3:07 PM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; olaf@aepfle.de;
> jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] Add support for netvsc build without
> CONFIG_SYSFS flag
> 
> On Thu, May 08, 2014 at 03:13:19PM +0000, Haiyang Zhang wrote:
> >
> >
> > > -----Original Message-----
> > > From: Greg KH [mailto:greg@kroah.com]
> > > Sent: Thursday, May 8, 2014 5:13 AM
> > > To: Haiyang Zhang
> > > Cc: davem@davemloft.net; netdev@vger.kernel.org; olaf@aepfle.de;
> > > jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> > > kernel@vger.kernel.org
> > > Subject: Re: [PATCH net-next] Add support for netvsc build without
> > > CONFIG_SYSFS flag
> > >
> > > On Wed, May 07, 2014 at 03:45:04PM -0700, Haiyang Zhang wrote:
> > > > This change ensures the driver can be built successfully without
> > > > the CONFIG_SYSFS flag.
> > > > MS-TFS: 182270
> > > >
> > > > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > > > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > > > ---
> > > >  drivers/net/hyperv/hyperv_net.h   |    2 ++
> > > >  drivers/net/hyperv/netvsc_drv.c   |   12 +++++++++++-
> > > >  drivers/net/hyperv/rndis_filter.c |    4 ++--
> > > >  3 files changed, 15 insertions(+), 3 deletions(-)
> > > >
> > > > diff --git a/drivers/net/hyperv/hyperv_net.h
> > > > b/drivers/net/hyperv/hyperv_net.h index 4b7df5a..23b96bc 100644
> > > > --- a/drivers/net/hyperv/hyperv_net.h
> > > > +++ b/drivers/net/hyperv/hyperv_net.h
> > > > @@ -87,6 +87,8 @@ struct ndis_recv_scale_cap { /*
> > > > NDIS_RECEIVE_SCALE_CAPABILITIES */  #define HASH_KEYLEN
> > > > NDIS_RSS_HASH_SECRET_KEY_MAX_SIZE_REVISION_2
> > > >  extern u8 netvsc_hash_key[];
> > > >
> > > > +extern unsigned int netvsc_num_queue;
> > > > +
> > > >  struct ndis_recv_scale_param { /* NDIS_RECEIVE_SCALE_PARAMETERS
> */
> > > >  	struct ndis_obj_header hdr;
> > > >
> > > > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > > > b/drivers/net/hyperv/netvsc_drv.c index 939e3af..07896f3 100644
> > > > --- a/drivers/net/hyperv/netvsc_drv.c
> > > > +++ b/drivers/net/hyperv/netvsc_drv.c
> > > > @@ -52,6 +52,8 @@ static int ring_size = 128;
> > > > module_param(ring_size, int, S_IRUGO);
> > > > MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
> > > >
> > > > +unsigned int netvsc_num_queue = 1;
> > > > +
> > > >  static void do_set_multicast(struct work_struct *w)  {
> > > >  	struct net_device_context *ndevctx = @@ -639,9 +641,11 @@ int
> > > > netvsc_recv_callback(struct hv_device *device_obj,
> > > >  		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
> > > >  				       packet->vlan_tci);
> > > >
> > > > +#ifdef CONFIG_SYSFS
> > > >  	skb_record_rx_queue(skb, packet->channel->
> > > >  			    offermsg.offer.sub_channel_index %
> > > >  			    net->real_num_rx_queues);
> > > > +#endif
> > >
> > > Why is this a sysfs-only function?  It should have nothing to do with sysfs,
> right?
> > > So why would the driver care?
> >
> > Without CONFIG_SYSFS the multi-receive queues are not allocated, see
> > below, and the variable real_num_rx_queues is not defined, so we skip this
> function.
> >
> > In alloc_netdev_mqs(), file "net/core/dev.c":
> > #ifdef CONFIG_SYSFS
> >         dev->num_rx_queues = rxqs;
> >         dev->real_num_rx_queues = rxqs;
> >         if (netif_alloc_rx_queues(dev))
> >                 goto free_all;
> > #endif
> 
> Then you need to structure your driver better :)

I have submitted an update patch.

Thanks,
- Haiyang
