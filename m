From: Simon Xiao <sixiao@microsoft.com>
Subject: RE: [PATCH net-next,v2,1/1] hv_netvsc: introduce netif-msg into
 netvsc module
Date: Fri, 24 Apr 2015 22:52:24 +0000
Message-ID: <CY1PR03MB137688C6CC69DBFC097F6031C4EC0@CY1PR03MB1376.namprd03.prod.outlook.com>
References: <1429900488-7302-1-git-send-email-sixiao@microsoft.com>
 <1429907357.23327.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429907357.23327.14.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, April 24, 2015 1:29 PM
> To: Simon Xiao
> Cc: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next,v2,1/1] hv_netvsc: introduce netif-msg into
> netvsc module
> 
> On Fri, 2015-04-24 at 11:34 -0700, sixiao@microsoft.com wrote:
> > From: Simon Xiao <sixiao@microsoft.com>
> >
> > 1. Introduce netif-msg to netvsc to control debug logging output and
> > keep msg_enable in netvsc_device_context so that it is kept
> > persistently.
> > 2. Only call dump_rndis_message() when NETIF_MSG_RX_ERR or above is
> > specified in netvsc module debug param.
> > In non-debug mode, in current code, dump_rndis_message() will not
> dump
> > anything but it still initialize some local variables and process the
> > switch logic which is unnecessary, especially in high network
> > throughput situation.
> 
> []
> 
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > b/drivers/net/hyperv/netvsc_drv.c
> []
> > @@ -888,6 +891,11 @@ static int netvsc_probe(struct hv_device *dev,
> >
> >  	net_device_ctx = netdev_priv(net);
> >  	net_device_ctx->device_ctx = dev;
> > +	net_device_ctx->msg_enable = netif_msg_init(debug, default_msg);
> > +	if (netif_msg_probe(net_device_ctx))
> > +		netdev_dbg(net, "netvsc msg_enable: %d",
> > +			   net_device_ctx->msg_enable);
> 
> Please use newlines to terminate formats.
> 
> It helps prevent log content interleaving when multiple processes are
> emitting output at the same time.
> 
> This could be shortened to use netif_<level> like:
> 
> 	netif_dbg(net_device_ctx, probe, net, "netvsc_msg_enable: %d\n",
> 		  net_device_ctx->msg_enable);
> 

Thanks Joe. I would like to leave this to my next patch as there are some places else in netvsc (rndis_filter.c) 
have the same usage. I would like to fix them in one patch to make them consistent.

Thanks,
Simon 
