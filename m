From: jamal <hadi@cyberus.ca>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Sat, 16 Oct 2010 07:35:59 -0400
Message-ID: <1287228959.3664.72.camel@bigi>
References: <20100830062755.GA22396@verge.net.au>
	 <87k4n8ow1r.fsf@benpfaff.org> <1287142292.3642.19.camel@bigi>
	 <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>, netdev@vger.kernel.org,
	ovs-team@nicira.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42265 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab0JPLgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 07:36:06 -0400
Received: by gyg13 with SMTP id 13so296217gyg.19
        for <netdev@vger.kernel.org>; Sat, 16 Oct 2010 04:36:05 -0700 (PDT)
In-Reply-To: <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse,

I re-added the other address Ben put earlier on in case you 
missed it.
yes, I have heard of TL;DR but unlike Alan Cox i find it hard to 
make a point in one sentence of 3 words - so please bear with me 
and read on.

On Fri, 2010-10-15 at 14:35 -0700, Jesse Gross wrote:

> 
> You're right, at a high level, it appears that there is a bit of an
> overlap between bridging, tc, and Open vSwitch.  

It looks like openvswitch rides on top of openflow, correct?
earlier i was looking at  openflow/datapath but gleaning
openvswitch/datapath it still looks conceptually the same
at the lower level. 

> However, in reality each is targeting a pretty different use case.  

Sure, use cases differences typically map either to policy 
or extension/addition of a new mechanism.
To clarify - you have the following approach per VM:

-->ingress port --> filter match --> actions 

Did i get this right?

You have a classifier that has 10 or so tuples. I could
replicate it with the u32 classifier - but it could be argued
that a brand new "hard-coded" classifier would be needed.

You have a series of actions like: redirect/mirror to port, drop etc
I can do most of these with existing tc actions and maybe replicate
most (like the vlan, MAC address, checksum etc rewrites) with pedit
action - but it could be argued that maybe one or more new tc actions
are needed.

Note: in linux, the above ingress port could be replaced with an
egress port instead. Bridging and L3 come after the actions in
the ingress path; and post that we have exactly the same approach of
port->filter->action

> Given that the design
> goals are not aligned, keeping separate things separate actually helps
> with overall simplicity.  

In general i would agree with the simplicity sentiment - but i fail to
see it so far.
A lot of the complexity, such as your own proprietary headers for flows
+actions, doesnt need to sit in the kernel.
IOW, the semantics of openflow already exist albeit a different syntax.
You can map the syntax to semantic in user space. This adheres to the
principal of simple kernel and external policy. 
I am sure thats what you would need to do with openflow on top of an
ASIC chip for example, no? I can see from the website you already run on
top of broadcom and marvel...

> Where there is overlap, I am certainly happy
> to see common functionality reused: for example, Open vSwitch uses tc
> for its QoS capabilities.

Refer to above. 

> In the future, I expect there to be an even clearer delineation
> between the various components.  One of the primary use cases of Open
> vSwitch at the moment is for virtualized data center networking but a
> few of the other potential uses that have been brought up include
> security processing (involving sending traffic of interest to
> userspace) and configuring SR-IOV NICs (to appropriately program rules
> in hardware).  You can see how each of these makes sense in the
> context of a virtual switch datapath but less so as a set of tc
> actions.

Unless i am misunderstanding - these are clearly more control extensions
but I dont see any of it needing to be in the kernel. It is all control
path stuff.
i.e something in user space (maybe even in a hypervisor) that is aware
of the virtualization creates, destroys and manages the VMs (SR-IOV etc)
and then configures per-VM flows whether directly in the kernel or via
some ethtool or other interface to the NIC.

> So, in short, I don't see this as something lacking in Linux, just
> complementary functionality.

Like i said above, I dont see the complimentary part.

cheers,
jamal

