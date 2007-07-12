From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Thu, 12 Jul 2007 15:53:47 +0900 (JST)
Message-ID: <20070712.155347.73365465.noboru.obata.ar@hitachi.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
    <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
    <468041C6.4060309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, davem@davemloft.net,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:35918 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbXGLGxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 02:53:55 -0400
Received: from mlsv11.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id EF5E437AC6
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:53:53 +0900 (JST)
In-Reply-To: <468041C6.4060309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 15:29:26 -0700

> Ian McDonald wrote:
> > On 6/26/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
> > 
> >> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> >>
> >> Make TCP_RTO_MAX a variable, and allow a user to change it via a
> >> new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> >> then guarantee TCP retransmission to be more controllable, say,
> >> at least once per 10 seconds, by setting it to 10.  This is
> >> quite helpful on failover-capable network devices, such as an
> >> active-backup bonding device.  On such devices, it is desirable
> >> that TCP retransmits a packet shortly after the failover, which
> >> is what I would like to do with this patch.  Please see
> >> Background and Problem below for rationale in detail.
> >>
> > RFC2988 says this:
> >   (2.4) Whenever RTO is computed, if it is less than 1 second then the
> >         RTO SHOULD be rounded up to 1 second.
> > 
> >         Traditionally, TCP implementations use coarse grain clocks to
> >         measure the RTT and trigger the RTO, which imposes a large
> >         minimum value on the RTO.  Research suggests that a large
> >         minimum RTO is needed to keep TCP conservative and avoid
> >         spurious retransmissions [AP99].  Therefore, this
> >         specification requires a large minimum RTO as a conservative
> >         approach, while at the same time acknowledging that at some
> >         future point, research may show that a smaller minimum RTO is
> >         acceptable or superior.
> > 
> >   (2.5) A maximum value MAY be placed on RTO provided it is at least 60
> >         seconds.
> > 
> > Your code doesn't seem to meet requirements of section 2.5 as your
> > minimum is 1 second.
> 
> (At the risk of having another Emily Litella moment entering a 
> discussion late...)
> 
> I thought that those sorts of things were generally referring to the 
> _default_ setting?

I believe so.  And the requirement of section 2.5 is rather weak
(it says "MAY").

Any comments from others?

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
