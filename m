From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Tue, 13 Oct 2009 10:34:32 -0400
Message-ID: <20091013143432.GJ6843@kvack.org>
References: <200910121143.39924.denys@visp.net.lb> <200910130144.04910.denys@visp.net.lb> <1255436477.6305.2.camel@dogo.mojatatu.com> <200910131545.36946.denys@visp.net.lb> <1255438959.6305.13.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:39982 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759903AbZJMPKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 11:10:21 -0400
Content-Disposition: inline
In-Reply-To: <1255438959.6305.13.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

On Tue, Oct 13, 2009 at 09:02:38AM -0400, jamal wrote:
> On Tue, 2009-10-13 at 15:45 +0300, Denys Fedoryschenko wrote:
> > Another bottleneck is u32 (i can optimize but) and some strange locks 
> > appearing at top of perf, maybe same as logon case.
> 
> like you say u32 can be optimized
> 
> > And yes, pppd also appearing, but seems just registering new sysctls (for new 
> > interface?) takes a lot of resources.
> > 
> 
> back in the days (when i was involved in pppoe) pppd was a big problem
> because it was not rentrant, so to solve the problem you exec a new
> process for each user..
> Ben Lahaise did a lot of work in this area and i am pretty sure decided
> not to use pppd.

Yes, I've been maintaining the ppp implementation (Babylon) initially 
written by SpellCaster back in '98.  My main focus of late has been 
dealing with PPPoE and L2TP, and specifically with terminating a lot of 
L2TP LNS traffic.  Babylon itself scales fairly well to large numbers of 
interfaces, as does the network stack these days.  Currently the bottleneck 
in interface creation is in the sysctl code.

The other big problem with large numbers of interfaces is interface 
deletion.  The synchronize_rcu() call in the interface teardown ends up 
making a single daemon with thousands of interfaces take a long time 
to clean up after itself.

		-ben
