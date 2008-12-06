From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Fri, 5 Dec 2008 16:26:08 -0800
Message-ID: <20081205162608.43ab0864@s6510>
References: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<4937D494.8080202@trash.net>
	<4939683D.40406@candelatech.com>
	<20081206092448.0c83d606.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<4939C269.4010609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44373 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546AbYLFA0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 19:26:14 -0500
In-Reply-To: <4939C269.4010609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Dec 2008 16:08:09 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Mark Smith wrote:
> > Hi,
> 
> > Would handling of frames for promiscuous macvlan interfaces be quite
> > similar to handling of incoming broadcast and multicast frames e.g.
> > for an incoming frame, walk through the list of macvlan interfaces (or
> > a separate list of promiscuous macvlan interfaces) that are currently in
> > promiscuous mode, and hand them a copy of the incoming frame?
> 
> That could probably work.
> 
> >> You might try using a pair of VETH interfaces to bridge between
> >> your host and virtual host.
> >>
> > 
> > What I was fundamentally trying to achieve was to avoid using any more
> > than one physical interface on the box (excepting a separate
> > management interface) to do this testing. While I happened to have
> > another unused interface I could bridge this virtual host onto, in some
> > cases you might not. Conceptually when using them, it is very easy to
> > think of the macvlan interfaces as nothing very different to having
> > multiple physical interfaces sitting on the same LAN segment. In my
> > scenario, bridging only one of them for this specific case of a
> > virtual guest host seemed like quite a logical thing to do.
> > 
> > Would veth interfaces facilitate the sharing of a single physical
> > interface between bridged and non-bridged processes on the host?
> 
> A Veth pair is like two ports linked back to each other..what is tx'd on one
> is rx'd on the other.
> 
> You could probably add eth0, veth1a, veth2a to a bridge,
> then add macvlans on veth1b and have your virtual guest
> talk to veth2b.
> 
> I do similar things with my redirdev devices, which are almost identical
> to veths, so I think it will work.
> 


Why bother, a macvlan is just a special case of a bridge, so why not
just bridge everything?
