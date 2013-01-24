From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid with wfica
Date: Thu, 24 Jan 2013 14:51:20 +0100
Message-ID: <20130124135120.GD16641@order.stressinduktion.org>
References: <20130123161238.GE8912@reaktio.net> <20130123214445.GA16641@order.stressinduktion.org> <20130123215151.GF8912@reaktio.net> <20130123152642.4a8389ba@nehalam.linuxnetplumber.net> <20130123234116.GC16641@order.stressinduktion.org> <1358984831.12374.1227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48595 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab3AXNvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 08:51:21 -0500
Content-Disposition: inline
In-Reply-To: <1358984831.12374.1227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 03:47:11PM -0800, Eric Dumazet wrote:
> On Thu, 2013-01-24 at 00:41 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Jan 23, 2013 at 03:26:42PM -0800, Stephen Hemminger wrote:
> > > I see no problems when using Citrix.
> > > This is a normal strace of the program wifca (in idle loop)
> > 
> > Thanks, could you also have a look at setsockopts while socket creation and
> > connection establishment?
> 
> As I said, tp->snd_cwnd is set to 0 by a bug in TCP stack.

I saw this, too, but hoped to see a reproduceable pattern of setsockopts
(window clamping, switching of congestion control) that could make citrix in
some way the special application which causes this. 

> Probably a combination of changed sysctls, and a genuine bug.
> 
> Please give us /etc/sysctl.conf content.
> 
> Adding some BUG_ON(!tp->snd_cwnd) on every writes to tp->snd_cwnd should
> catch the bug.

But this is much more convenient, yes. :)
