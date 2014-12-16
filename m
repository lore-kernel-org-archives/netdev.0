From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Tue, 16 Dec 2014 11:01:32 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DB15CA@ORSMSX101.amr.corp.intel.com>
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
 <E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com>
 <548F6E62.1040500@mojatatu.com>
 <E4CD12F19ABA0C4D8729E087A761DC3505DA6149@ORSMSX101.amr.corp.intel.com>
 <548F88E8.1010703@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50872 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbaLPLCQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 06:02:16 -0500
In-Reply-To: <548F88E8.1010703@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In my reply (inline) I elaborate on the validity of bridge-less and offloaded-bridge models for L2 switching.

I also discuss the implied necessity of a bridge device for L3 routing and potential issues with the upcoming FIB offloading proposal.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
> Sent: Tuesday, December 16, 2014 3:21 AM
> To: Arad, Ronen
> Cc: Jamal Hadi Salim; John Fastabend; netdev@vger.kernel.org; Jiri Pirko;
> sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
> stephen@networkplumber.org; linville@tuxdriver.com;
> vyasevic@redhat.com; davem@davemloft.net;
> shm@cumulusnetworks.com; gospo@cumulusnetworks.com
> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
> bridge port attributes
> 
> On 12/15/14, 4:58 PM, Arad, Ronen wrote:
> >
> >> -----Original Message-----
> >> From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
> >> Sent: Tuesday, December 16, 2014 1:28 AM
> >> To: Arad, Ronen; John Fastabend; netdev@vger.kernel.org
> >> Cc: Roopa Prabhu; Jiri Pirko; sfeldma@gmail.com; bcrl@kvack.org;
> >> tgraf@suug.ch; stephen@networkplumber.org; linville@tuxdriver.com;
> >> vyasevic@redhat.com; davem@davemloft.net;
> shm@cumulusnetworks.com;
> >> gospo@cumulusnetworks.com
> >> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and
> >> del bridge port attributes
> >>
> >> On 12/15/14 13:36, Arad, Ronen wrote:
> >>>
> >>>> -----Original Message-----
> >>> The behavior of a driver could depend on the presence of a bridge
> >>> and
> >> features such as FDB LEARNING and LEARNING_SYNC.
> >>
> >> Indeed, those are bridge attributes.
> >>
> >>> A switch port driver which is not enslaved to a bridge might need to
> >>> implement VLAN-aware FDB within the driver and report its content to
> >>> user-
> >> space using ndo_fdb_dump.
> >>   >
> >>> A switch port driver which is enslaved to a bridge could do with
> >>> only pass through for static FDB configuration
> >>   > to the HW when LEARNING_SYNC is configured. FDB reporting to
> >> user- space and soft aging are left to the bridge module FDB.
> >>> Such driver, without LEARNING_SYNC could still avoid maintaing
> >>> in-driver
> >> FDB as long as it could dump the HW FDB on demand.
> >>> LEARNING_SYNC also requires periodic updates of freshness
> >>> information
> >> from the driver to the bridge module.
> >>
> >> If you have an fdb - shouldnt that be exposed only if you have a
> >> bridge abstraction exposed? i.e thats where the Linux tools would work.
> > I'm trying to find out what are the opinions of other people in the netdev
> list.
> > John have clearly stated that he'd like to see full L2 switching functionality
> (at least) supported without making a bridge device mandatory.
> > The existing bridge ndos (ndo_bridge_{set,del,get}link) already support that
> with proper setting of SELF/MASTER flags by iproute2.
> > I see the value in supporting both approaches (bridge device mandatory
> > and bridge device optional). If the choice is left to user-driven policy decision,
> > we need to document both use models and map traditional L2 features to
> > each model.
> > The L2 offloading (or NETFUNC as it is currently called), which is being
> > discussed on a different patch-set, is only needed when a bridge device is
> > used.
> > Without a bridge device, all configuration has to be targeted at the switch
> > port driver directly using the SELF flag. FDB remains relevant and it is used to
> > configure static MAC table entries and dump the HW MAC table.

> Your understanding is right here. So far all patches have kept both models in
> mind.


> > When the HW device is a L2 switch or a multi-layer switch (L2-L3 or even
> > higher), there is a gap between what the HW is doing and what is explicitly
> > modeled in Linux.


> Can you elaborate more here ?. We use the linux model to accelerate a
> multi-layer (l2-l3) switch today. There maybe a few gaps, but these gaps can
> be closed by having equivalent functionality in the software path.

What I meant is that without a bridge device the HW switch is seen as a collection of independent switch ports. Typical switch ASIC performs L2 switching by default. This is not expressed explicitly in Linux without a bridge device.
The SELF flag is used to target typical bridge port and bridge configuration at a switch port device.
Without an explicit bridge device, bridge attributes have to be directed at an arbitrary port (any port could represent the entire switch) and interpreted by the switch port driver as intended for the entire switch (this includes attributes like STP etc.)
Each switch port device driver has to implement similar functionality (i.e. all bridge and fdb related ndos) independently without common functionality shared (e.g. FDB, soft aging).
It is a valid use model and could avoid the complexity of having to deal with the presence of both SW and HW bridge and to deal with explicit offloading of data-path.

I was trying to find out whether the intention was to continue and support both bridge-less an offloaded-bridge models and leave it to the end-user to choose the desirable model at configuration time.
This would require dual support in the switch port driver in order to have best user experience across multiple switch ASICs or other kinds of devices.


> 
> > Without a bridge device, the HW is represented by a set of switch port
> > devices and the bridging (both control and data planes) takes place only in
> > the HW and switch port driver.
> > Each switch port driver has to implement its own FDB as there is no
> > common shared code among drivers for different HW devices.
> > Using a bridge device could partially alleviate that, but it comes with a cost.
> > There is a need to properly implement offloading of both configuration and
> > data-path. The transmit and receive path in the bridge module should be
> > somehow bypassed to avoid unnecessary overhead or duplicate packets
> > coming from both software bridging and HW bridging.
> >
> >> What i was refering to was a scenario where i have no interest in the
> >> fdb despite such a hardware capabilities. VLANs is a different issue;
> >>
> > VLAN is fundamental feature of L2 and L3 switching and Linux is unclear
> about it. Bridge device could model bridging of untagged packets which
> requires a bridge device for each VLAN and a vlan device on each port that is
> a member of the bridge's VLAN.
> > This different from the behavior and configuration of classic closed-source
> switches.
> > An alternative model is VLAN filtering where a bridge is VLAN-aware and
> > switches tagged traffic. A bridge device represents multiple L2 domains with
> > VLAN filtering policy that defines the switching rules within each domain.
> And the linux bridge driver supports both models today.
> 
> > Forwarding (e.g. L3 routing) is expected across such L2 domains using L3
> entities.
> > The modeling of L3 entities per L2 domain (e.g. per-VLAN) in the VLAN
> > filtering model is yet unclear to me.

> In the vlan filtering bridge model, You can create a vlan device on the bridge
> for l3 ...
> 

That's what I'm thinking too (I experimented with such setup using veth interfaces, bridge device, and vlan interfaces). This, however, seems to require an explicit bridge for L3 support.

Looking at the latest code of FIB offloading (not yet submitted to netdev), I noticed that a switch port device is expected as a lower descendent of the FIB destination device.
This assumption is valid in the per-vlan bridge model where IP address is assigned to the bridge itself.
This, however, is not consistent with the single multi-VLAN bridge model.
Vlan interfaces on a bridge looks like siblings of the switch ports devices on the same bridge. They are not ancestors of the switch ports.
The L3 domain ends at the bridge sub-interfaces. The only L3 entities are the vlan sub-interfaces on the bridge. 
Those are route next hops and the only possible fib_dev.
L3 routing is not aware of the switch ports. Route is performed to next hop addresses on one of the vlan interfaces subnets. The actual resolution to a switch port device has to be performed by the neighbor subsystem (ARP/ND).
It is unclear to me how the FIB offloading will be redirected to an ndo of a switch port device.

> >
> >>>>> Will the decision about using a bridge device or avoiding it be
> >>>>> left to the end-user?
> >>>> Its a user policy decision. Again the offload bit gets us this in a
> >>>> reasonably configurable way IMO.
> >>>>
> >>>>> (This requires switch port drivers to be able to work and provide
> >>>>> similar functionality in both setups).
> >>>> Right, but if the drivers "care" who is calling their ndo ops
> >>>> something is seriously broken. For the driver it should not need to
> >>>> know anything about the callers so it doesn't matter to the driver
> >>>> if its a netlink call from user space or an internal call fro
> >>>> bridge.ko
> >>> LEARNING_SYNC only makes sense when a switch port driver is enslaved
> >>> to
> >> a bridge.
> >>   > Rocker switch driver indeed monitors upper change notifications
> >> and keep track of master bridge presence.
> >>> So bridge presence is not transparent.
> >>>
> >> Agreed - the challenge so far is that people have been fascinated by
> "switch"
> >> point of view. I think we are learning and the class device will
> >> eventually become obvious as useful.
> >>
> >> cheers,
> >> jamal
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org More majordomo
> info
> > at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
