From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Tue, 23 Apr 2013 14:27:35 +0800
Message-ID: <1366698455.21136.11.camel@cr0>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
	 <20130422.160834.1941810644323096368.davem@davemloft.net>
	 <1366687841.21136.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754857Ab3DWG1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 02:27:46 -0400
In-Reply-To: <1366687841.21136.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 11:30 +0800, Cong Wang wrote:
> On Mon, 2013-04-22 at 16:08 -0400, David Miller wrote:
> > 
> > Please do not fix this by adding Kconfig dependencies, you have to
> > find another way.  In bonding and bridging, we've made it such that
> > you can configure them in any combination whatsoever with ipv6 and
> > everything works properly.  Most of them time this can be accomplished
> > by moving things into the explicit "obj-y" objects in
> > net/ipv6/Makefile
> 
> One quick solution is just linking mcast.o statically, because it is not
> easy to separate core functions from mcast.c like addrconf_core.c.
> 
> > 
> > If you are adding stateful dependencies upon ipv6 (you want to inspect
> > the ipv6 routes or something like that), I'm sorry but I really don't
> > want any hard dependies on ipv6's internal state, we can't export that
> > properly.
> 
> I don't think we need that.
> 

After several tries, I think it is not easy to do at all, it relies on
some icmp functions at least, which are still compiled as a module. So,
I can't think out any easier solution than simply adding Kconfig
dependency.

Or maybe I should raise the question again: should we forbid compiling
IPv6 as a module from now on? At least some popular distributions
already use CONFIG_IPV6=y. The only IPv6 things we really need to
compile as a module is probably just procfs/sysfs stuffs.

Thanks.
