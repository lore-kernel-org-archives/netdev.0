From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 15:06:05 -0700 (PDT)
Message-ID: <20070510.150605.94557473.davem@davemloft.net>
References: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
	<20070510.144007.62663063.davem@davemloft.net>
	<4643939B.3000904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, johnpol@2ka.mipt.ru,
	krkumar2@in.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: gaagaan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753042AbXEJWGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 18:06:03 -0400
In-Reply-To: <4643939B.3000904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gagan Arneja <gaagaan@gmail.com>
Date: Thu, 10 May 2007 14:50:19 -0700

> David Miller wrote:
> 
> > If you drop the TX lock, the number of free slots can change
> > as another cpu gets in there queuing packets.
> 
> Can you ever have more than one thread inside the driver? Isn't 
> xmit_lock held while we're in there?

There are restrictions wrt. when the xmit_lock and the
queue lock can be held at the same time.

The devil is definitely in the details if you try to
implemen this.  It definitely lends support for Eric D.'s
assertion that this change will only add bugs and doing
something simple like prefetches is proabably a safer
route to go down.
