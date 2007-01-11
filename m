From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Thu, 11 Jan 2007 09:29:59 +0100
Message-ID: <20070111082958.GB1672@ff.dom.local>
References: <20070110125048.GB2611@ff.dom.local> <20070110120123.52376578@freekitty> <20070111072428.GA1672@ff.dom.local> <20070110.234035.102123688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, greearb@candelatech.com,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:50715 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030225AbXAKI2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 03:28:05 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070110.234035.102123688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 11:40:35PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Thu, 11 Jan 2007 08:24:28 +0100
> 
> > Yesterday I did what I should do earlier - checked
> > this simple way, with printk, and now I have no doubts
> > it's a bug: if you add or remove vlan devices with
> > vconfig, register_vlan_device and unregister_vlan_dev
> > are called by ioctl and they use and change rcu
> > procetded data without preemption disabled so vlan
> > rcu hash lists could become corrupted or find results
> > could be wrong.
> 
> Those two operations do their modifications and changes under the RTNL
> semaphore, via rtnl_lock() and rtnl_unlock() which guarentees that no
> other modifications can occur.

Sure, but is this even legal to be preempted during
reading or modifying rcu list? Doesn't this disturb
rcu cycle and make possible memory release problems?

Jarek P.
