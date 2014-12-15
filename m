From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del bridge port attributes
Date: Mon, 15 Dec 2014 13:03:08 -0500
Message-ID: <20141215180308.GD6942@kvack.org>
References: <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com> <548F1852.7090507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	sfeldma@gmail.com, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35236 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbaLOSDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 13:03:09 -0500
Content-Disposition: inline
In-Reply-To: <548F1852.7090507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 15, 2014 at 09:20:18AM -0800, Roopa Prabhu wrote:
> On 12/15/14, 7:26 AM, Jamal Hadi Salim wrote:
> >
> >Sorry - i didnt quiet follow the discussion, but i can see the value
> >of propagating things from parent to children netdevs as part of the
> >generic approach. And in that spirit:
> >
> >Ben's patches (and I am sure the cumulus folk do this) expose ports.
> >i.e you boot up the hardware and you see ports. You can then put these
> >ports in a bridge and you can offload fdbs and do other parametrization
> >to the ASIC. IOW, this only becomes a bridge because you created one
> >in the kernel and attached bridge ports to it.
> >
> >Lets say i didnt want a bridge. I want instead to take these exposed
> >ports and create a bond (and maybe play with LACP). How does this
> >propagation from parent->child->child work then? I think the idea
> >of just bonding and not exposing it as a switch is a reasonable use
> >case.
> 
> We have not come to pure bonding and lacp yet (but i have mentioned it 
> in many contexts before).
> The use case you mention is offloading bond attributes. This will be 
> addressed as part of ongoing switchdev work
> for all other offloads (bonds, vxlans etc).
> Right now we are only talking bridge port attribute offload 
> (learn/flood/port state etc). This could still be a bridge port 
> attribute on a bond
> when the bond is a bridge port.

This raises the question: do we track which attributes are configured 
onto a port in the switchdev code (in an attempt to maintain the state 
on behalf of the underlying device), or do we simply pass them in as 
attributes of the config request?  With stacking, I can see the need 
for different layers to add different attributes to the config for a 
given switch port.  Things like bonding would need to make note of the 
bond interface with a common identifier so that the switch can figure 
out to put the different ports into the same group.

The rtl8366s has support for one 802.3ad group, so it looks like I will 
need to tackle this.

		-ben

> >Also how does it work when i start doing L3 and the bond's port doesnt
> >support L3? Is it time to revive the thing we called TheThing in Du?
> yes, exactly. This is what i had indicated in my initial emails on this 
> thread when the stacked devices topic came up.
> Since there was reluctance in introducing a switch device (theThing), My 
> current patch tries to do that without a switch device.
> Since this is still l2, and we are dealing with bridge port attributes, 
> my current patch traverses the stacked netdevs to call the 
> ndo_bridge_setlink on the switch port.
> 
> When it comes to l3, we can follow the same.., but as discussed in Du, 
> there are other reasons where a switch device becomes necessary.
> I can submit an alternate series to cover the switch device approach for 
> l2 as well.
> 
> Thanks,
> Roopa
> 

-- 
"Thought is the essence of where you are now."
