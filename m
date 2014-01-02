From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable lo
Date: Thu, 2 Jan 2014 07:03:18 +0100
Message-ID: <20140102060318.GA22494@order.stressinduktion.org>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com> <20130619.230532.1329281330568271336.davem@davemloft.net> <20131231035718.GB27636@order.stressinduktion.org> <52C4FDBE.5030607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	kumaran.4353@gmail.com, netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaABGDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 01:03:20 -0500
Content-Disposition: inline
In-Reply-To: <52C4FDBE.5030607@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 01:48:46PM +0800, chenweilong wrote:
> On 2013/12/31 11:57, Hannes Frederic Sowa wrote:
> > On Wed, Jun 19, 2013 at 11:05:32PM -0700, David Miller wrote:
> >> From: Gao feng <gaofeng@cn.fujitsu.com>
> >> Date: Sun, 16 Jun 2013 11:14:30 +0800
> >>
> >>> If we disable all of the net interfaces, and enable
> >>> un-lo interface before lo interface, we already allocated
> >>> the addrconf dst in ipv6_add_addr. So we shouldn't allocate
> >>> it again when we enable lo interface.
> >>>
> >>> Otherwise the message below will be triggered.
> >>> unregister_netdevice: waiting for sit1 to become free. Usage count = 1
> >>>
> >>> This problem is introduced by commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> >>> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> >>>
> >>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >>
> >> This is the second such regression added by that commit :-/
> >>
> >> Applied and queue up for -stable, thanks.
> > 
> > Hmm, and this change also has a regression and breaks the original fix. :/
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=67951
> > 
> > I tried to track it down but it seems pretty complicated. Maybe we have to
> > special-case the take-down of the loopback device.
> > 
> > 
> > 
> 
> When I did the tests,If 'ifconfig lo down',all IPv6 connection broken,
> but IPv4 connection were still OK.
> 
> Is it designed like that or a bug?

It is designed this way.

Greetings,

  Hannes
