From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Sat, 22 Nov 2008 00:18:07 +0800
Message-ID: <20081121161455.M43757@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <20081120212045.27879d22@extreme> <20081120.213627.210066076.davem@davemloft.net> <20081120224542.10feb72d@extreme>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Cc: akeem@jmicron.com, ethanhsiao@jmicron.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:50430 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757586AbYKUQ33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:29:29 -0500
In-Reply-To: <20081120224542.10feb72d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Nov 2008 22:45:42 -0800, Stephen Hemminger wrote
> On Thu, 20 Nov 2008 21:36:27 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 20 Nov 2008 21:20:45 -0800
> > 
> > > 6. Not using pci dma allocation which is more standard convention
> > 
> > Using the generic DMA interfaces is actually preferred.  There is
> > no effective difference other than using a more generic interface.
> 
> Ok, but this???
> 
> #define NET_STAT(priv) (priv->dev->stats)
> #define NETDEV_GET_STATS(netdev, fun_ptr)
> #define DECLARE_NET_DEVICE_STATS
> 
> #define DECLARE_NAPI_STRUCT struct napi_struct napi;
> #define NETIF_NAPI_SET(dev, napis, pollfn, q) \
> 	netif_napi_add(dev, napis, pollfn, q);
> #define JME_NAPI_HOLDER(holder) struct napi_struct *holder
> #define JME_NAPI_WEIGHT(w) int w
> #define JME_NAPI_WEIGHT_VAL(w) w
> #define JME_NAPI_WEIGHT_SET(w, r)
> #define JME_RX_COMPLETE(dev, napis) netif_rx_complete(dev, napis)
> #define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
> #define JME_NAPI_DISABLE(priv) \
> 	if (!napi_disable_pending(&priv->napi)) \
> 		napi_disable(&priv->napi);
> #define JME_RX_SCHEDULE_PREP(priv) \
> 	netif_rx_schedule_prep(priv->dev, &priv->napi)
> #define JME_RX_SCHEDULE(priv) \
> 	__netif_rx_schedule(priv->dev, &priv->napi);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

You are right about it.
I have another jme.h which can compile for older kernel.
It can be removed if it should be.

Guo-Fu Tseng

