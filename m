From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Fri, 05 Dec 2008 16:08:09 -0800
Message-ID: <4939C269.4010609@candelatech.com>
References: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org>	<4937D494.8080202@trash.net>	<4939683D.40406@candelatech.com> <20081206092448.0c83d606.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53524 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbYLFAIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 19:08:16 -0500
In-Reply-To: <20081206092448.0c83d606.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith wrote:
> Hi,

> Would handling of frames for promiscuous macvlan interfaces be quite
> similar to handling of incoming broadcast and multicast frames e.g.
> for an incoming frame, walk through the list of macvlan interfaces (or
> a separate list of promiscuous macvlan interfaces) that are currently in
> promiscuous mode, and hand them a copy of the incoming frame?

That could probably work.

>> You might try using a pair of VETH interfaces to bridge between
>> your host and virtual host.
>>
> 
> What I was fundamentally trying to achieve was to avoid using any more
> than one physical interface on the box (excepting a separate
> management interface) to do this testing. While I happened to have
> another unused interface I could bridge this virtual host onto, in some
> cases you might not. Conceptually when using them, it is very easy to
> think of the macvlan interfaces as nothing very different to having
> multiple physical interfaces sitting on the same LAN segment. In my
> scenario, bridging only one of them for this specific case of a
> virtual guest host seemed like quite a logical thing to do.
> 
> Would veth interfaces facilitate the sharing of a single physical
> interface between bridged and non-bridged processes on the host?

A Veth pair is like two ports linked back to each other..what is tx'd on one
is rx'd on the other.

You could probably add eth0, veth1a, veth2a to a bridge,
then add macvlans on veth1b and have your virtual guest
talk to veth2b.

I do similar things with my redirdev devices, which are almost identical
to veths, so I think it will work.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

