From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Thu, 20 Nov 2008 22:45:42 -0800
Message-ID: <20081120224542.10feb72d@extreme>
References: <20080915165101.M68109@cooldavid.org>
	<20081120212045.27879d22@extreme>
	<20081120.213627.210066076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	ethanhsiao@jmicron.com, akeem@jmicron.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56203 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbYKUGpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 01:45:45 -0500
In-Reply-To: <20081120.213627.210066076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Nov 2008 21:36:27 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 20 Nov 2008 21:20:45 -0800
> 
> > 6. Not using pci dma allocation which is more standard convention
> 
> Using the generic DMA interfaces is actually preferred.  There is
> no effective difference other than using a more generic interface.

Ok, but this???


#define NET_STAT(priv) (priv->dev->stats)
#define NETDEV_GET_STATS(netdev, fun_ptr)
#define DECLARE_NET_DEVICE_STATS

#define DECLARE_NAPI_STRUCT struct napi_struct napi;
#define NETIF_NAPI_SET(dev, napis, pollfn, q) \
	netif_napi_add(dev, napis, pollfn, q);
#define JME_NAPI_HOLDER(holder) struct napi_struct *holder
#define JME_NAPI_WEIGHT(w) int w
#define JME_NAPI_WEIGHT_VAL(w) w
#define JME_NAPI_WEIGHT_SET(w, r)
#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(dev, napis)
#define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
#define JME_NAPI_DISABLE(priv) \
	if (!napi_disable_pending(&priv->napi)) \
		napi_disable(&priv->napi);
#define JME_RX_SCHEDULE_PREP(priv) \
	netif_rx_schedule_prep(priv->dev, &priv->napi)
#define JME_RX_SCHEDULE(priv) \
	__netif_rx_schedule(priv->dev, &priv->napi);
