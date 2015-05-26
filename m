From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: Socket receives packet to multicast group to which it was not
 joined since kernel 3.13.10-1
Date: Tue, 26 May 2015 12:41:13 -0500
Message-ID: <20150526174113.GA17751@sbohrermbp13-local.rgmadvisors.com>
References: <5370F8EB.2070009@oktetlabs.ru>
 <1399915082.7973.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <5371BAE1.2090806@oktetlabs.ru>
 <20140513213641.GA19087@sbohrermbp13-local.rgmadvisors.com>
 <20140514204010.GA5719@sbohrermbp13-local.rgmadvisors.com>
 <loom.20150524T065137-105@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oliver Graff <oliver.e.graff@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:32768 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbEZRlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:41:16 -0400
Received: by oiww2 with SMTP id w2so83638854oiw.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:41:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <loom.20150524T065137-105@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 24, 2015 at 04:55:40AM +0000, Oliver Graff wrote:
> Shawn Bohrer <shawn.bohrer <at> gmail.com> writes:
> 
> > 
> > On Tue, May 13, 2014 at 04:36:41PM -0500, Shawn Bohrer wrote:
> 
> > > If I did "break" something here it appears to be because with
> > > ip_early_demux we only call ip_check_mc_rcu() once on the initial
> > > packet, and subsequent packets destined for that socket simply need to
> > > pass the __udp_is_mcast_sock() test.  With ip_early_demux disaled we
> > > call ip_check_mc_rcu() for every packet.
> > 
> > So is the solution to effectively call ip_check_mc_rcu() inside
> > udp_v4_early_demux()?
> > 
> > --
> > Shawn
> > 
> (See earlier parts of thread here: 
> http://netdev.vger.kernel.narkive.com/mwurLsMT/socket-receives-packet-to-multicast-
> group-to-which-it-was-not-joined-since-kernel-3-13-10-1)
> 
> Was a bug report filed for this / was this fixed? 
> I looked at the diffs from the referenced commit and the current version of 
> udp_v4_early_demux and the changes appear to be 
> minimal,
> it doesn't look like ip_check_mc_rcu was added. Is that all that's needed?

Hi Oliver,

I haven't tested but looking over the code I would say that this has
not been fixed.  Is this issue impacting you?

I think calling ip_check_mc_rcu (you might need some of the code from
ip_route_input_noref too) might "fix" the issue, though I have not
tried.  My concern is that early demux is a performance optimization
and I don't know how much this would impact multicast receive
performance.

As Eric mentioned in the earlier email if you don't care about
performance you can simply disable early demux:

echo 0 >/proc/sys/net/ipv4/ip_early_demux

--
Shawn
