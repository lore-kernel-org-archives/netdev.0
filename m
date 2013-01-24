From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Thu, 24 Jan 2013 08:59:08 +0200
Message-ID: <20130124065908.GG8912@reaktio.net>
References: <20130123161238.GE8912@reaktio.net>
 <20130123214445.GA16641@order.stressinduktion.org>
 <20130123215151.GF8912@reaktio.net>
 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
 <20130123234116.GC16641@order.stressinduktion.org>
 <1358984831.12374.1227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:34330 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab3AXG7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 01:59:12 -0500
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
> 
> Probably a combination of changed sysctls, and a genuine bug.
> 
> Please give us /etc/sysctl.conf content.
> 

This is my /etc/sysctl.conf contents:


net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1

net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

vm.min_free_kbytes = 131072
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.wmem_default = 262144
net.core.rmem_default = 262144
net.ipv4.tcp_rmem = 4096 262144 16777216
net.ipv4.tcp_wmem = 4096 262144 16777216


> Adding some BUG_ON(!tp->snd_cwnd) on every writes to tp->snd_cwnd should
> catch the bug.
> 

Hmm, I think I'll try this..


-- Pasi
 
