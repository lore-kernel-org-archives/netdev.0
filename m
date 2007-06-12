From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Tue, 12 Jun 2007 18:32:37 -0500
Message-ID: <20070612233237.GN4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58742 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbXFLXcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 19:32:39 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CNWc7q028637
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 19:32:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CNWc64339514
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 19:32:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CNWbSe001408
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 19:32:38 -0400
Content-Disposition: inline
In-Reply-To: <466F2581.2080808@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 07:00:17PM -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
> >>On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
> >>>On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> >>>>On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> >>>>>The major bug fixes are: 
> >>>>I realise it's late, but shouldn't "major bugfixes" be going into 22 ?
> >>>Yeah, I suppose, I admit I've lost track of the process. 
> >>You need to order your bug fixes first in the queue. 
> >
> >OK, here are the patches, re-ordered. There is a different number
> >than last time, as I threw out one, merged one, and got cold feet
> >on a third one.  They still pass the tests.
> >
> >The first five patches focus on three serious bugs, fixing crashes or
> >hangs.
> >
> >-- patch 1 -- kernel crash when ifdown while receiving packets.
> >-- patch 2,3,4 -- device driver deadlocks on "RX ram full" mesgs.
> >                  (kernel stays up, ifdown/up clear the problem).
> >-- patch 5 -- misconfigured TX interrupts results in 3x-4x per
> >              degradation for small packets.
> >
> >-- patch 6 -- rx stats may be mangled
> >-- patch 7 -- hw checksum sometimes breaks ipv6 operation
> >
> >-- patches 8-15 -- misc tweaks, and documentation.
> >
> >
> >I re-ran my stress tests with patches 1-7 applied; they pass.
> 
> This is a bit frustrating, because this includes many patches that you 
> ALREADY told me to queue for 2.6.23, which I did, in 
> netdev-2.6.git#upstream.

Sigh. I redid the series so as to avoid this problem, per the 
previous conversation. 

> Should I just drop all spidernet patches and start over?

No. Apply the series I just sent you, dropping the one called
"patch 6/15", the one from Florin Malita, as it appears you'd
previously picked this up.  The rest of the patches should apply
cleanly; I just cheked. I just did a "git pull" of 
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
and checked. The result of patching is exactly as it should be.

Just in case it wasn't clear, I'd like to see patches 1-5 go
into 2.6.22 ... as these address the most critical complaints I'd
gotten recently.

--linas

