From: David Miller <davem@davemloft.net>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Fri, 02 May 2008 05:45:36 -0700 (PDT)
Message-ID: <20080502.054536.109642865.davem@davemloft.net>
References: <008f01c8ac51$83dbd5d0$6400a8c0@bui.materna.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, g4klx@g4klx.demon.co.uk
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750976AbYEBMph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 08:45:37 -0400
In-Reply-To: <008f01c8ac51$83dbd5d0$6400a8c0@bui.materna.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Roland" <devzero@web.de>
Date: Fri, 2 May 2008 14:38:36 +0200

> it seems it`s lapbether driver
> 
> reproduce:
> 
> on system with pcnet32 (vmware) do
> 
> modprobe pcnet32
> modprobe lapbether
> modprobe -r lapbether
> modprobe -r pcnet32 -> hang -> unregister_netdevice: waiting for eth0 to 
> become free

lapbeth_cleanup_driver() unregisters the netdevice, but does not
release the reference to lapbeth->ethdev in those device instances.

Once this happens, and the lapbeth_dev_notifier is unregistered,
these references will leak forever.
