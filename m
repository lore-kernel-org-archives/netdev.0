From: Simon Horman <horms@verge.net.au>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Mon, 18 Oct 2010 17:20:10 +0200
Message-ID: <20101018152010.GE319@verge.net.au>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <1287142292.3642.19.camel@bigi>
 <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
 <1287228959.3664.72.camel@bigi>
 <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
 <1287404217.3664.182.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>,
	netdev@vger.kernel.org, ovs-team@nicira.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48911 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab0JRPTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 11:19:44 -0400
Content-Disposition: inline
In-Reply-To: <1287404217.3664.182.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 08:16:57AM -0400, jamal wrote:
> 
> On Sat, 2010-10-16 at 12:33 -0700, Jesse Gross wrote:
> > On Sat, Oct 16, 2010 at 4:35 AM, jamal <hadi@cyberus.ca> wrote:

[ snip ]

> > 2. A mechanism to send/receive packets to/from userspace.  This is an
> > important component that Open vSwitch adds to the pipeline.  This will
> > probably expand in the future to suit different applications, like the
> > security processing that I talked about.
> 
> There are many ways to skin that proverbial cat. I guess it will depend
> on whether you are redirecting or merely copying a whole packet, or part
> of it (while storing a part in the kernel) etc. Example for a scheme
> that works using netlink look at the netfilter examples. You could use
> pf_packet if merely requiring copies. One simple scheme i have used is
> to have the mirred action redirect to a tun device on which a user space
> daemon is listening. If you look at the mirred action - there is an
> option to redirect to a named socket which was never implemented because
> workarounds exist.

As I understand things, the packet goes from the kernel to userspace
and then (typically) comes back again.

I guess that it would be possible to send a copy of the headers
to user-sapce while the packet is quarantined in the kernel pending
a response from user-space. I say only the headers, as typically
that is all user-space needs to make a decision, though I guess it
may need the body to make some types of decisions. I have no idea
if such a scheme would be desirable in any circumstances.

