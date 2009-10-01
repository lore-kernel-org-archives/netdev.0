From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 19:43:44 +0300
Message-ID: <200910011943.44625.cratiu@ixiacom.com>
References: <200910011916.40908.cratiu@ixiacom.com> <20091001092100.14ea024b@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:4908 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754271AbZJAQnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:43:41 -0400
In-Reply-To: <20091001092100.14ea024b@s6510>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 October 2009 19:21:00 Stephen Hemminger wrote:
> On Thu, 1 Oct 2009 19:16:40 +0300
>
> Cosmin Ratiu <cratiu@ixiacom.com> wrote:
> > Hello,
> >
> > This is a patch that adds a sysctl to control the sending of the Target
> > Link Layer Address Option (TLLAO) with Neighbor Advertisements responding
> > to unicast NS. The patch was made for kernel 2.6.7 (yes it is ancient),
> > but the code is similar with the current kernel and I can rework it if
> > you want it in.
> >
> > RFC 2461, page 24 suggests that this option should be included with NAs
> > to avoid a race with the sender clearing its cache after sending an
> > unicast NS, but before receiving a NA.
> >
> > It seems there are some Juniper routers (MX series) that expect this
> > option to be included with all NAs.
> >
> > Another solution is to always send this option, as it has little
> > overhead.
> >
> > Please let me know what you think,
> > Cosmin.
> >
> > Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
> > --- //packages/linux_2.6.7/main/src/include/linux/sysctl.h
> > +++ /home/z/w1/packages/linux_2.6.7/main/src/include/linux/sysctl.h
> > @@ -444,6 +444,7 @@
> >         NET_IPV6_IP6FRAG_TIME=23,
> >         NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,
> >         NET_IPV6_MLD_MAX_MSF=25,
> > +       NET_IPV6_NDISC_FORCE_TLLAO=26,
>
> Since numbered sysctl values are deprecated, can you use CTL_UNNUMBERED
> to avoid having to add yet another value?

Of course, but that is a detail.
If you decide on the sysctl solution, I'll do it.
If you decide on making this the default behavior, it's even better.

Cosmin.
