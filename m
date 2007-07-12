From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Thu, 12 Jul 2007 21:54:36 +1200
Message-ID: <5640c7e00707120254u7fa2f963gfe07637f2f6eb891@mail.gmail.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
	 <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
	 <468041C6.4060309@hp.com>
	 <20070712.155347.73365465.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, davem@davemloft.net,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: "OBATA Noboru" <noboru.obata.ar@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:22528 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299AbXGLJyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 05:54:38 -0400
Received: by nz-out-0506.google.com with SMTP id s18so87061nze
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 02:54:37 -0700 (PDT)
In-Reply-To: <20070712.155347.73365465.noboru.obata.ar@hitachi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
> > Ian McDonald wrote:
> > > On 6/26/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
> > >
> > >> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> > >>
> > >> Make TCP_RTO_MAX a variable, and allow a user to change it via a
> > >> new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> > >> then guarantee TCP retransmission to be more controllable, say,
> > >> at least once per 10 seconds, by setting it to 10.  This is
> > >> quite helpful on failover-capable network devices, such as an
> > >> active-backup bonding device.  On such devices, it is desirable
> > >> that TCP retransmits a packet shortly after the failover, which
> > >> is what I would like to do with this patch.  Please see
> > >> Background and Problem below for rationale in detail.
> > >>
> > > RFC2988 says this:
> > >   (2.4) Whenever RTO is computed, if it is less than 1 second then the
> > >         RTO SHOULD be rounded up to 1 second.
> > >
> > >         Traditionally, TCP implementations use coarse grain clocks to
> > >         measure the RTT and trigger the RTO, which imposes a large
> > >         minimum value on the RTO.  Research suggests that a large
> > >         minimum RTO is needed to keep TCP conservative and avoid
> > >         spurious retransmissions [AP99].  Therefore, this
> > >         specification requires a large minimum RTO as a conservative
> > >         approach, while at the same time acknowledging that at some
> > >         future point, research may show that a smaller minimum RTO is
> > >         acceptable or superior.
> > >
> > >   (2.5) A maximum value MAY be placed on RTO provided it is at least 60
> > >         seconds.
> > >
> > > Your code doesn't seem to meet requirements of section 2.5 as your
> > > minimum is 1 second.
> >
> > (At the risk of having another Emily Litella moment entering a
> > discussion late...)
> >
> > I thought that those sorts of things were generally referring to the
> > _default_ setting?
>
> I believe so.  And the requirement of section 2.5 is rather weak
> (it says "MAY").
>
It is weak in saying you don't have to have a maximum, but if you do
have one IT IS AT LEAST 60 seconds (emphasis mine). So the time period
is a strong requirement if you decide to implement - which is a weak
requirement.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
