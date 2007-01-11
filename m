From: David Miller <davem@davemloft.net>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Wed, 10 Jan 2007 23:40:35 -0800 (PST)
Message-ID: <20070110.234035.102123688.davem@davemloft.net>
References: <20070110125048.GB2611@ff.dom.local>
	<20070110120123.52376578@freekitty>
	<20070111072428.GA1672@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, greearb@candelatech.com,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60088
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965319AbXAKHkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 02:40:37 -0500
To: jarkao2@o2.pl
In-Reply-To: <20070111072428.GA1672@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Thu, 11 Jan 2007 08:24:28 +0100

> Yesterday I did what I should do earlier - checked
> this simple way, with printk, and now I have no doubts
> it's a bug: if you add or remove vlan devices with
> vconfig, register_vlan_device and unregister_vlan_dev
> are called by ioctl and they use and change rcu
> procetded data without preemption disabled so vlan
> rcu hash lists could become corrupted or find results
> could be wrong.

Those two operations do their modifications and changes under the RTNL
semaphore, via rtnl_lock() and rtnl_unlock() which guarentees that no
other modifications can occur.
