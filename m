From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take3
Date: Thu, 12 Jul 2007 12:39:17 -0700
Message-ID: <20070712123917.5d54fbaa@freepuppy.rosehill.hemminger.net>
References: <20070705193748.D018.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44310 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753955AbXGLTja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 15:39:30 -0400
In-Reply-To: <20070705193748.D018.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 05 Jul 2007 20:11:16 +0900
Masakazu Mokuno <mokuno@sm.sony.co.jp> wrote:

> Hi, 
> 
> This is the third submission of the network driver for PS3.
> The differences from the previous one are:
> 
>   - renamed source file names so that their prefix can match
>     with the module name
>   - added cbe-oss-dev@ozlabs.org line for MAINTAINER file
>   - changed some in copyright comments
>   
> If there are no more comments, please apply for 2.6.23. 
>

This isn't a show stopper. But could you consider integrating vlan
support with existing VLAN acceleration hooks?


Please remove GELIC_NET_GET_MODE/GELIC_NET_SET_MODE, they seem
to be ioctl's left over from an earlier version.

You don't need a net_device_stats element in gelic_net_card because
it is already included in net_device structure in recent kernels.

Why make ethtool support conditional. It should always be enabled.

Don't call netif_poll_enable() in net_open. It is unnecessary and
racy. 

It is better to use device name (ie eth0) as name of irq for request_irq()
because the user level IRQ balancer has some heuristics that know that
names of form "ethX" are network devices.  May not matter on PS3 because
it isn't true SMP.

You are wasting memory by always allocating full maximum receive size buffers.
Your max mtu is 2308 so the allocation will end up being rounded up to 4K
so that costs twice as much memory as allocating a standard 1518 (or 1536)
size Ethernet MTU buffer.

