From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Sat, 6 Dec 2008 09:24:48 +1030
Message-ID: <20081206092448.0c83d606.ipng@69706e6720323030352d30312d31340a.nosense.org>
References: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<4937D494.8080202@trash.net>
	<4939683D.40406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.mail.adnap.net.au ([203.6.132.75]:50428 "EHLO
	smtp1.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbYLEW4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 17:56:13 -0500
In-Reply-To: <4939683D.40406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 05 Dec 2008 09:43:25 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Patrick McHardy wrote:
> 
> >> Should what I'm doing be working or possible? If not, could something
> >> be added to the kernel to prevent macvlan interfaces being added to
> >> bridge instances, to stop other people spending time trying to do what
> >> I've tried to do?
> > 
> > Unfortunately one of both combinations will not work, no matter
> > what we do. The bridge code could issue a warning when adding
> > a bridge on top of a macvlan device, but there's no clean indication
> > that something is a macvlan device besides dev->rtnl_link_ops->kind
> > being "macvlan".
> 
> A mac-vlan can't really be PROMISC either since it only receives
> BCAST frames and packets destined for it's own MAC, so I can't see
> how it could work in a bridge....
> 

Would handling of frames for promiscuous macvlan interfaces be quite
similar to handling of incoming broadcast and multicast frames e.g.
for an incoming frame, walk through the list of macvlan interfaces (or
a separate list of promiscuous macvlan interfaces) that are currently in
promiscuous mode, and hand them a copy of the incoming frame?

> user-space brctl could check for the driver string returned by
> ethtool API to check if no one wants any additional cruft in
> the kernel...
> 
> 
> You might try using a pair of VETH interfaces to bridge between
> your host and virtual host.
> 

What I was fundamentally trying to achieve was to avoid using any more
than one physical interface on the box (excepting a separate
management interface) to do this testing. While I happened to have
another unused interface I could bridge this virtual host onto, in some
cases you might not. Conceptually when using them, it is very easy to
think of the macvlan interfaces as nothing very different to having
multiple physical interfaces sitting on the same LAN segment. In my
scenario, bridging only one of them for this specific case of a
virtual guest host seemed like quite a logical thing to do.

Would veth interfaces facilitate the sharing of a single physical
interface between bridged and non-bridged processes on the host?

Regards,
Mark.
