From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 1/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 23:18:21 -0700 (PDT)
Message-ID: <20090828.231821.228158617.davem@davemloft.net>
References: <200908290518.n7T5IdjW031875@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amathur@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751701AbZH2GSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:18:07 -0400
In-Reply-To: <200908290518.n7T5IdjW031875@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You're going to have to remove all of the
__ESX_COS__, __VMKERNEL_MODULE__, __VMKNETDDI_QUEUEOPS__
ifdef tests and protected code in this driver.

Nothing sets those CPP defines, and the Linux kernel is not
a place where you can maintain your compatability code for
building the driver in other environments.

Next, you have defined your own implementation of a driver
debug logging facility, when we have a generic one already
for network drivers via netif_msg_*() and associated
NETIF_MSG_* debugging masks.  See other drivers for details.
If it doesn't fully suit your needs, fix the existing
facilities to do so.

These are just the most obvious things I noticed by glancing
quickly at your driver.  I'm sure there a many other things
you will need to fix up before we can add your driver.

The code is 1MB in size, which almost guarentees there are lots of
things which will need to be removed :-) Even the largest 10GB drivers
with tons of firmware are ~500K in size and I even consider that
bordering on excessive.
