From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Mon, 15 Dec 2014 18:36:25 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com>
 <20141210093755.GB1863@nanopsycho.orion>
 <5489CBBA.7050302@cumulusnetworks.com>
 <20141211171145.GG1912@nanopsycho.orion>
 <5489DB73.1080808@cumulusnetworks.com>
 <20141211180743.GA2010@nanopsycho.orion>
 <5489E214.4080708@cumulusnetworks.com>
 <20141211222559.GB1880@nanopsycho.orion>
 <548D9B14.9010201@cumulusnetworks.com>
 <20141214153549.GA2174@nanopsycho.orion>
 <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com>
 <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com>
 <548F20FF.9080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29763 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbaLOSim convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 13:38:42 -0500
In-Reply-To: <548F20FF.9080508@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: John Fastabend [mailto:john.fastabend@gmail.com]
> Sent: Monday, December 15, 2014 7:57 PM
> To: Arad, Ronen
> Cc: Jamal Hadi Salim; Roopa Prabhu; Jiri Pirko; netdev@vger.kernel.org;
> sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
> stephen@networkplumber.org; linville@tuxdriver.com;
> vyasevic@redhat.com; davem@davemloft.net;
> shm@cumulusnetworks.com; gospo@cumulusnetworks.com
> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
> bridge port attributes
> 
> On 12/15/2014 09:25 AM, Arad, Ronen wrote:
> >
> >
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> owner@vger.kernel.org] On Behalf Of Jamal Hadi Salim
> >> Sent: Monday, December 15, 2014 5:26 PM
> >> To: Roopa Prabhu; Jiri Pirko
> >> Cc: sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
> >> john.fastabend@gmail.com; stephen@networkplumber.org;
> >> linville@tuxdriver.com; vyasevic@redhat.com; netdev@vger.kernel.org;
> >> davem@davemloft.net; shm@cumulusnetworks.com;
> >> gospo@cumulusnetworks.com
> >> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and
> >> del bridge port attributes
> >>
> >>
> >> Sorry - i didnt quiet follow the discussion, but i can see the value
> >> of propagating things from parent to children netdevs as part of the
> >> generic approach. And in that spirit:
> >>
> >> Ben's patches (and I am sure the cumulus folk do this) expose ports.
> >> i.e you boot up the hardware and you see ports. You can then put
> >> these ports in a bridge and you can offload fdbs and do other
> >> parametrization to the ASIC. IOW, this only becomes a bridge because
> >> you created one in the kernel and attached bridge ports to it.
> >>
> >> Lets say i didnt want a bridge. I want instead to take these exposed
> >> ports and create a bond (and maybe play with LACP). How does this
> >> propagation from
> >> parent->child->child work then? I think the idea of just bonding and
> >> parent->child->not
> >> exposing it as a switch is a reasonable use case.
> >
> 
> > Are you saying that the software should reflect the same functionality
> > the HW provides?
> > In other words is creating a bridge device mandatory for supporting
> > standard VLAN-bridging (as in IEEE 802.1Q) in the HW?
> 
> No it shouldn't be mandatory. And I don't think it is at the moment.
> Users are free to manage the FDB tables directly via netlink or configure the
> software bridge to sync them. This seems like a good model to follow to me
> and we should try to get as many features as it makes sense to follow this
> model.
> 
> > VLAN-bridging including port VLAN membership, VLAN filtering, PVID,
> > Egress un-tagging could be supported without an explicit bridge device
> > when port devices implement bridge ndos (ndo_bridge_{set,del,get}link).
> > What is lost is the ability to have common handling of VLAN-aware FDB
> > in the bridge module.
> 
> not sure what is lost here? Its seems the SW bridge does (or at least
> could) support the same vlan capabilities. And the bridge could push these
> into hardware when Roopa's offload bit is set. Or if users want to manage
> everything outside bridge calling the ndo_bridge_ ops directly works as well.
> By the way I believe the software linux bridge supports most of those
> features you listed today. If we missed something we can add it.
> 
> > Do we expect switch port devices to support L2 functionality both ways
> > (with and without an explicit bridge device)?
> 
> My opinion yes. But in fact the driver shouldn't care what is driving it. The
> paths should be the same for direct user manipulation via netlink and
> SELF|MASTER bit, bridge module, or any other in-kernel sub-system.
> 
The behavior of a driver could depend on the presence of a bridge and features such as FDB LEARNING and LEARNING_SYNC.
A switch port driver which is not enslaved to a bridge might need to implement VLAN-aware FDB within the driver and report its content to user-space using ndo_fdb_dump. 
A switch port driver which is enslaved to a bridge could do with only pass through for static FDB configuration to the HW when LEARNING_SYNC is configured. FDB reporting to user-space and soft aging are left to the bridge module FDB.
Such driver, without LEARNING_SYNC could still avoid maintaing in-driver FDB as long as it could dump the HW FDB on demand.
LEARNING_SYNC also requires periodic updates of freshness information from the driver to the bridge module.

> > Will the decision about using a bridge device or avoiding it be left
> > to the end-user?
> 
> Its a user policy decision. Again the offload bit gets us this in a reasonably
> configurable way IMO.
> 
> > (This requires switch port drivers to be able to work and provide
> > similar functionality in both setups).
> 
> Right, but if the drivers "care" who is calling their ndo ops something is
> seriously broken. For the driver it should not need to know anything about
> the callers so it doesn't matter to the driver if its a netlink call from user
> space or an internal call fro bridge.ko

LEARNING_SYNC only makes sense when a switch port driver is enslaved to a bridge. Rocker switch driver indeed monitors upper change notifications and keep track of master bridge presence. So bridge presence is not transparent.
> 
> > I think that we need to outline the handling of L3 as it could
> > determine or at least impact some of the answers to my above questions.
> 
> L3 should follow the same model. Admittedly I've not worked through the
> L3 cases closely but I don't see why we can't apply the same model.
> And maybe this is where we need to introduce a container to hold some
> state as Jamal says. The easiest way to see this will be to look at some
> proposed code.
> 
> 
> > cheers,
> > ronen
> >
> >> Also how does it work when i start doing L3 and the bond's port
> >> doesnt support L3? Is it time to revive the thing we called TheThing in Du?
> >>
> >> cheers,
> >> jamal
> >>
> >> On 12/14/14 14:41, Roopa Prabhu wrote:
> >>> On 12/14/14, 7:35 AM, Jiri Pirko wrote:
> >>
> >> [..chopped off for brevity and saving electrons..]
> >>
> >> cheers,
> >> jamal
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org More majordomo
> >> info at http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> John Fastabend         Intel Corporation
