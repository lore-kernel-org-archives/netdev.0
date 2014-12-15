From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Mon, 15 Dec 2014 17:25:00 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4961 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbaLORfp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:35:45 -0500
In-Reply-To: <548EFD94.8070905@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jamal Hadi Salim
> Sent: Monday, December 15, 2014 5:26 PM
> To: Roopa Prabhu; Jiri Pirko
> Cc: sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
> john.fastabend@gmail.com; stephen@networkplumber.org;
> linville@tuxdriver.com; vyasevic@redhat.com; netdev@vger.kernel.org;
> davem@davemloft.net; shm@cumulusnetworks.com;
> gospo@cumulusnetworks.com
> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
> bridge port attributes
> 
> 
> Sorry - i didnt quiet follow the discussion, but i can see the value of
> propagating things from parent to children netdevs as part of the generic
> approach. And in that spirit:
> 
> Ben's patches (and I am sure the cumulus folk do this) expose ports.
> i.e you boot up the hardware and you see ports. You can then put these
> ports in a bridge and you can offload fdbs and do other parametrization to
> the ASIC. IOW, this only becomes a bridge because you created one in the
> kernel and attached bridge ports to it.
> 
> Lets say i didnt want a bridge. I want instead to take these exposed ports and
> create a bond (and maybe play with LACP). How does this propagation from
> parent->child->child work then? I think the idea of just bonding and not
> exposing it as a switch is a reasonable use case.

Are you saying that the software should reflect the same functionality the HW provides?
In other words is creating a bridge device mandatory for supporting standard VLAN-bridging (as in IEEE 802.1Q) in the HW?
VLAN-bridging including port VLAN membership, VLAN filtering, PVID, Egress un-tagging could be supported without an explicit bridge device when port devices implement bridge ndos (ndo_bridge_{set,del,get}link). What is lost is the ability to have common handling of VLAN-aware FDB in the bridge module.
Do we expect switch port devices to support L2 functionality both ways (with and without an explicit bridge device)?
Will the decision about using a bridge device or avoiding it be left to the end-user?
(This requires switch port drivers to be able to work and provide similar functionality in both setups).
I think that we need to outline the handling of L3 as it could determine or at least impact some of the answers to my above questions.

cheers,
ronen
 
> Also how does it work when i start doing L3 and the bond's port doesnt
> support L3? Is it time to revive the thing we called TheThing in Du?
> 
> cheers,
> jamal
> 
> On 12/14/14 14:41, Roopa Prabhu wrote:
> > On 12/14/14, 7:35 AM, Jiri Pirko wrote:
> 
> [..chopped off for brevity and saving electrons..]
> 
> cheers,
> jamal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
