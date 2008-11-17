From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2]netdevice: 82596: Convert netdev->priv to
 netdev_priv
Date: Mon, 17 Nov 2008 01:29:39 -0800 (PST)
Message-ID: <20081117.012939.72047312.davem@davemloft.net>
References: <4921095D.9010109@cn.fujitsu.com>
	<20081116.223637.108010315.davem@davemloft.net>
	<49213856.6040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbYKQJ3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 04:29:40 -0500
In-Reply-To: <49213856.6040802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 17 Nov 2008 17:24:38 +0800

> The memory, which pointed by netdev->priv, can be allocated by alloc_etherdev().
> We don't need to use __get_free_pages() to get memory.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

I don't think this is right either.

There might be device imposed alignment constraints, for example.

And a whole page is also being allocated so that this cache mode
change doesn't have an effect on unrelated kernel memory.  That could
kill performance if some critical other data structure sits in the
same page and now has it's cacheability disabled.
