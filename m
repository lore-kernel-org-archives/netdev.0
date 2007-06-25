From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 15:28:18 -0700
Message-ID: <20070625152818.0d70477a@freepuppy.localdomain.hemminger.net>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
	<5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "OBATA Noboru" <noboru.obata.ar@hitachi.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52146 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751909AbXFYW3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 18:29:08 -0400
In-Reply-To: <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jun 2007 10:18:46 +1200
"Ian McDonald" <ian.mcdonald@jandi.co.nz> wrote:

> On 6/26/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
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
> >
> RFC2988 says this:
>    (2.4) Whenever RTO is computed, if it is less than 1 second then the
>          RTO SHOULD be rounded up to 1 second.
> 
>          Traditionally, TCP implementations use coarse grain clocks to
>          measure the RTT and trigger the RTO, which imposes a large
>          minimum value on the RTO.  Research suggests that a large
>          minimum RTO is needed to keep TCP conservative and avoid
>          spurious retransmissions [AP99].  Therefore, this
>          specification requires a large minimum RTO as a conservative
>          approach, while at the same time acknowledging that at some
>          future point, research may show that a smaller minimum RTO is
>          acceptable or superior.
> 
>    (2.5) A maximum value MAY be placed on RTO provided it is at least 60
>          seconds.
> 
> Your code doesn't seem to meet requirements of section 2.5 as your
> minimum is 1 second.
> 
> I think if you're trying to solve the bonding issue then you should
> solve that issue, not hack the TCP implementation as that opens it up
> to abuse in other ways.
> 
> Ian

Another alternative is to provide a way to force all connections to retransmit
"right away" by adding a notifier mechanism.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
