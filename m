From: noboru.obata.ar@hitachi.com
Subject: Re: [MaybeSpam] Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a
    variable
Date: Thu, 28 Jun 2007 06:57:54 +0900 (JST)
Message-ID: <20070628.065754.132846467.noboru.obata.ar@hitachi.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
    <467FBFE2.7050605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, noboru.obata.ar@hitachi.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:55594 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbXF0V5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 17:57:54 -0400
Received: from mlsv10.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id A363F37C83
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2007 06:57:52 +0900 (JST)
In-Reply-To: <467FBFE2.7050605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> OBATA Noboru wrote:
> > From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> > 
> > Make TCP_RTO_MAX a variable, and allow a user to change it via a
> > new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> > then guarantee TCP retransmission to be more controllable, say,
> > at least once per 10 seconds, by setting it to 10.  This is
> > quite helpful on failover-capable network devices, such as an
> > active-backup bonding device.  On such devices, it is desirable
> > that TCP retransmits a packet shortly after the failover, which
> > is what I would like to do with this patch.  Please see
> > Background and Problem below for rationale in detail.
> 
> 
> Would it make sense to do this per route?

Well, for a certain case, maybe yes.

For example,

(1) You have both a fast route (link) and a slow route,
(2) You want to use a short RTO for the fast route and not for
    the slow route, and
(3) Routes are static, as mentioned by Siim.

On such a case, only a global tcp_rto_max, which is set to a
very small value, may overload the slow link due to many
retransmission packets.  Then, as Stephen mentioned, people will
find it useful to have per route tcp_rto_max.

But let me give you some number.

The number of retramsmission packets in the first 60[s] on
tcp_rto_max = 10[s], starting from RTO = 0.2[s], are:
	10 with tcp_rto_max = 10[s], where
	8 with tcp_rto_max = 120[s] (original).

Only extra 2 packets per minute per socket should be acceptable
in most cases.

So if you choose a moderate tcp_rto_max, you may not necessarily
need per route tcp_rto_max.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)

