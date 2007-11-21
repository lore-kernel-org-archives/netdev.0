From: <wyb@topsec.com.cn>
Subject: RE:RE: is it useful testing __LINK_STATE_RX_SCHED in dev_close()?
Date: Wed, 21 Nov 2007 15:09:52 +0800
Message-ID: <200711210712.AYG00766@topsec.com.cn>
References: <E1IuhbM-0006tD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Herbert Xu'" <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.topsec.com.cn ([202.99.27.222]:56384 "EHLO
	mail1.topsec.com.cn" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbXKUHKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 02:10:46 -0500
In-Reply-To: <E1IuhbM-0006tD-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


__LINK_STATE_RX_SCHED still exist in kernel 2.6.23.8.

Netdevice.h:

/* Test if receive needs to be scheduled */
static inline int __netif_rx_schedule_prep(struct net_device *dev)
{
	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
}

/* Test if receive needs to be scheduled but only if up */
static inline int netif_rx_schedule_prep(struct net_device *dev)
{
	return netif_running(dev) && __netif_rx_schedule_prep(dev);
}

Dev.c:
int dev_close(struct net_device *dev)
{
	...
	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
     	/* No hurry. */
         msleep(1);
    }
	...
}

Test_bit() in dev_close() maybe between the calling of netif_running() and
__netif_rx_schedule_prep() in netif_rx_schedule_prep.



