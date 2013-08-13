From: Joe Perches <joe@perches.com>
Subject: Re: question about drivers/net/ethernet/jme.{c,h}
Date: Tue, 13 Aug 2013 10:26:24 -0700
Message-ID: <1376414784.1949.39.camel@joe-AO722>
References: <alpine.DEB.2.02.1308131831250.2263@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46721 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758921Ab3HMR0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 13:26:25 -0400
In-Reply-To: <alpine.DEB.2.02.1308131831250.2263@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 18:33 +0200, Julia Lawall wrote:
> I wonder what is the point of the macro NETIF_NAPI_SET?

Today it seems pretty clear it's useless indirection.

It might have been useful sometime before the jme.c
file was first submitted, but now it should be removed.

In the jme.h file on JMicron's website, the driver
still supports linux versions less than 2.6.23 and
uses a form like this:

ftp://driver.jmicron.com.tw/Ethernet/Linux/jmebp-1.0.8.5.tar.bz

#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,23)
#define NETIF_NAPI_SET(dev, napis, pollfn, q) \
	dev->poll = pollfn; \
	dev->weight = q;
#else
#define NETIF_NAPI_SET(dev, napis, pollfn, q) \
	netif_napi_add(dev, napis, pollfn, q);
