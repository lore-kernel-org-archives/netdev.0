From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del bridge port attributes
Date: Mon, 15 Dec 2014 12:57:00 -0500
Message-ID: <20141215175700.GC6942@kvack.org>
References: <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com> <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35217 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbaLOR5C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 12:57:02 -0500
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 15, 2014 at 05:25:00PM +0000, Arad, Ronen wrote:
> > Ben's patches (and I am sure the cumulus folk do this) expose ports.
> > i.e you boot up the hardware and you see ports. You can then put these
> > ports in a bridge and you can offload fdbs and do other parametrization to
> > the ASIC. IOW, this only becomes a bridge because you created one in the
> > kernel and attached bridge ports to it.
> > 
> > Lets say i didnt want a bridge. I want instead to take these exposed ports and
> > create a bond (and maybe play with LACP). How does this propagation from
> > parent->child->child work then? I think the idea of just bonding and not
> > exposing it as a switch is a reasonable use case.
> 
> Are you saying that the software should reflect the same functionality the HW provides?
> In other words is creating a bridge device mandatory for supporting standard VLAN-bridging (as in IEEE 802.1Q) in the HW?

Re-using the existing Linux APIs for bridging is the approach I've taken 
with the rtl8366s driver I've been working on.  It makes no sense to create 
entirely new APIs for these operations.

> VLAN-bridging including port VLAN membership, VLAN filtering, PVID, Egress un-tagging could be supported without an explicit bridge device when port devices implement bridge ndos (ndo_bridge_{set,del,get}link). What is lost is the ability to have common handling of VLAN-aware FDB in the bridge module.
> Do we expect switch port devices to support L2 functionality both ways (with and without an explicit bridge device)?

I've already got egress untagging working if the VLANs are configured using 
vconfig and added to a bridge.  The lack of this functionality in the "new" 
API for bridging VLANs is a huge complaint I have about the new bridge 
configuration API.  I feel that API change was a step backwards in terms 
of functionality.  It also conflates the different FDBs for different VLANs 
into the same hash table, again, something i find rather messy compared to 
the 1 FDB to 1 bridge state the bridge device was in originally.

		-ben

> Will the decision about using a bridge device or avoiding it be left to the end-user?
> (This requires switch port drivers to be able to work and provide similar functionality in both setups).
> I think that we need to outline the handling of L3 as it could determine or at least impact some of the answers to my above questions.
> 
> cheers,
> ronen
>  
> > Also how does it work when i start doing L3 and the bond's port doesnt
> > support L3? Is it time to revive the thing we called TheThing in Du?
> > 
> > cheers,
> > jamal
> > 
> > On 12/14/14 14:41, Roopa Prabhu wrote:
> > > On 12/14/14, 7:35 AM, Jiri Pirko wrote:
> > 
> > [..chopped off for brevity and saving electrons..]
> > 
> > cheers,
> > jamal
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> > of a message to majordomo@vger.kernel.org More majordomo info at
> > http://vger.kernel.org/majordomo-info.html

-- 
"Thought is the essence of where you are now."
