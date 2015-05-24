From: Oliver Graff <oliver.e.graff@gmail.com>
Subject: Re: Socket receives packet to multicast group to which it was not joined since kernel 3.13.10-1
Date: Sun, 24 May 2015 04:55:40 +0000 (UTC)
Message-ID: <loom.20150524T065137-105@post.gmane.org>
References: <5370F8EB.2070009@oktetlabs.ru> <1399915082.7973.27.camel@edumazet-glaptop2.roam.corp.google.com> <5371BAE1.2090806@oktetlabs.ru> <20140513213641.GA19087@sbohrermbp13-local.rgmadvisors.com> <20140514204010.GA5719@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48362 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbbEXFAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2015 01:00:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YwO17-0002Sp-8P
	for netdev@vger.kernel.org; Sun, 24 May 2015 07:00:05 +0200
Received: from cpe-45-50-188-106.socal.res.rr.com ([45.50.188.106])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 07:00:05 +0200
Received: from oliver.e.graff by cpe-45-50-188-106.socal.res.rr.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 07:00:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Bohrer <shawn.bohrer <at> gmail.com> writes:

> 
> On Tue, May 13, 2014 at 04:36:41PM -0500, Shawn Bohrer wrote:

> > If I did "break" something here it appears to be because with
> > ip_early_demux we only call ip_check_mc_rcu() once on the initial
> > packet, and subsequent packets destined for that socket simply need to
> > pass the __udp_is_mcast_sock() test.  With ip_early_demux disaled we
> > call ip_check_mc_rcu() for every packet.
> 
> So is the solution to effectively call ip_check_mc_rcu() inside
> udp_v4_early_demux()?
> 
> --
> Shawn
> 
(See earlier parts of thread here: 
http://netdev.vger.kernel.narkive.com/mwurLsMT/socket-receives-packet-to-multicast-
group-to-which-it-was-not-joined-since-kernel-3-13-10-1)

Was a bug report filed for this / was this fixed? 
I looked at the diffs from the referenced commit and the current version of 
udp_v4_early_demux and the changes appear to be 
minimal,
it doesn't look like ip_check_mc_rcu was added. Is that all that's needed?

- Oliver
