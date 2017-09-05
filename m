From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 12:19:11 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5650@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <20170904023831.GA68062@cran64.bj.intel.com>
        <87mv6abte5.fsf@stressinduktion.org>
        <20170905021112.GA86057@cran64.bj.intel.com>
 <87vakxsaj2.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>, "e@erig.me" <e@erig.me>,
        "blp@ovn.org" <blp@ovn.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:47558 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdIEMTO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 08:19:14 -0400
In-Reply-To: <87vakxsaj2.fsf@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

Please have a look at the Google doc that sketches the overall solution to support NSH in OVS. 
https://drive.google.com/open?id=1oWMYUH8sjZJzWa72o2q9kU0N6pNE-rwZcLH3-kbbDR8

In details it is slightly outdated but the NSH MD1 support (and all prerequisites like PTAP and Generic Encap/Decap) have been implemented in OVS 2.8 (ofproto layer and the userspace datapath). 

The NSH use cases are discussed in the chapter "Support for NSH". OVS is primarily targeting the Classifier and SFF use cases. Obviously the classifier must be able to set the MD1 context headers. The final SFF must be able to inspect the context headers, typically to determine the L2 or L3 forwarding context (e.g. VRF) in which to forward the decapsulated packet on to its final destination.

This information has end-to-end significance for the SFP and is encoded by the classifier in the NSH context headers. It cannot be put into transport tunnel options of e.g. a Geneve tunnel connecting two SFFs along the SFP.

We are now trying to establish feature parity in the kernel datapath. If the kernel datapath chooses not to support the MD1 fields, OVS with kernel datapath will not be able to address the classifier and final SFF use cases.

BR, Jan

> -----Original Message-----
> From: Hannes Frederic Sowa [mailto:hannes@stressinduktion.org]
> Sent: Tuesday, 05 September, 2017 12:30
> To: Yang, Yi <yi.y.yang@intel.com>
> Cc: netdev@vger.kernel.org; dev@openvswitch.org; jbenc@redhat.com; e@erig.me; blp@ovn.org; Jan Scheurich
> <jan.scheurich@ericsson.com>
> Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH support
> 
> "Yang, Yi" <yi.y.yang@intel.com> writes:
> 
> > I'm not sure what new action you expect to bring here, I think group
> > action is just for this, as you said it isn't only bound to NSH, you can
> > start a new thread to discuss this. I don't think it is in scope of NSH.
> 
> It is in scope of this discussion as you will provide a user space API
> that makes the NSH context fields accessible from user space in a
> certain way. If you commit to this, there is no way going back.
> 
> I haven't yet grasped the idea on how those fields will be used in OVS
> besides load balancing. Even for load balancing the tunnel itself
> (vxlan-gpe + UDP source port or ipv6 flowlabel) already provides enough
> entropy to do per-flow load balancing. What else is needed?  Why a
> context header for that? You just need multiple action chains and pick
> one randomly.
> 
> The only protocol that I can compare that to is geneve with TLVs, but
> the TLVs are global and uniquie and a property of the networking
> forwarding backplane and not a property of the path inside a tenant. So
> I expect this actually to be the first case where I think that matters.
> 
> Why are context labels that special that they are not part of tun_ops?
> 
> Thanks,
> Hannes
