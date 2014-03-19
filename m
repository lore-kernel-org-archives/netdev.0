From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Wed, 19 Mar 2014 23:44:42 +0100
Message-ID: <20140319224442.GJ12291@order.stressinduktion.org>
References: <20140318175406.78339ffe@nehalam.linuxnetplumber.net> <20140319.001736.730011705431992209.davem@davemloft.net> <20140318235811.0d8f230a@nehalam.linuxnetplumber.net> <20140319.135319.2039055704156238608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47352 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609AbaCSWon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 18:44:43 -0400
Content-Disposition: inline
In-Reply-To: <20140319.135319.2039055704156238608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 01:53:19PM -0400, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 18 Mar 2014 23:58:11 -0700
> 
> > On Wed, 19 Mar 2014 00:17:36 -0400 (EDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> From: Stephen Hemminger <stephen@networkplumber.org>
> >> Date: Tue, 18 Mar 2014 17:54:06 -0700
> >> 
> >> > On Tue, 18 Mar 2014 01:29:08 +0100
> >> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> >> > 
> >> >> I wonder if we should put the whole ipv6_ifa_notify infrastructure in a
> >> >> workqueue? I don't like that either and it could add subtile races.
> >> > 
> >> > That is option, might be some call chains that already have rtnl_lock held.
> >> 
> >> There are TAHI ipv6 conformance tests that expect state changes to be
> >> precisely synchronous.

Exactly, I was afraid of those things (not exactly of TAHI breakage but of
real packet loss in case of late workqueue scheduling).

> >> And frankly it's pretty reasonable to send two packets back to back,
> >> one which causes the state change and one which tests if the state
> >> change happened, and expect that to work.
> > 
> > It is more the timer based state changes that are problematic because
> > they aren't acquire RTNL.
> 
> Ok, the timer stuff could run from a workqueue just fine.

We have no-timer invocations, too, like addrconf_prefix_rcv. In that case the
whole handling of the router advertisment should get deferred into the
workqueue.

Bye,

  Hannes
