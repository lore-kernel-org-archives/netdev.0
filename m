From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Mon, 15 Dec 2014 09:20:18 -0800
Message-ID: <548F1852.7090507@cumulusnetworks.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com> <20141210093755.GB1863@nanopsycho.orion> <5489CBBA.7050302@cumulusnetworks.com> <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com, bcrl@kvack.org,
	tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40999 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaLORUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:20:24 -0500
In-Reply-To: <548EFD94.8070905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/14, 7:26 AM, Jamal Hadi Salim wrote:
>
> Sorry - i didnt quiet follow the discussion, but i can see the value
> of propagating things from parent to children netdevs as part of the
> generic approach. And in that spirit:
>
> Ben's patches (and I am sure the cumulus folk do this) expose ports.
> i.e you boot up the hardware and you see ports. You can then put these
> ports in a bridge and you can offload fdbs and do other parametrization
> to the ASIC. IOW, this only becomes a bridge because you created one
> in the kernel and attached bridge ports to it.
>
> Lets say i didnt want a bridge. I want instead to take these exposed
> ports and create a bond (and maybe play with LACP). How does this
> propagation from parent->child->child work then? I think the idea
> of just bonding and not exposing it as a switch is a reasonable use
> case.

We have not come to pure bonding and lacp yet (but i have mentioned it 
in many contexts before).
The use case you mention is offloading bond attributes. This will be 
addressed as part of ongoing switchdev work
for all other offloads (bonds, vxlans etc).
Right now we are only talking bridge port attribute offload 
(learn/flood/port state etc). This could still be a bridge port 
attribute on a bond
when the bond is a bridge port.

> Also how does it work when i start doing L3 and the bond's port doesnt
> support L3? Is it time to revive the thing we called TheThing in Du?
yes, exactly. This is what i had indicated in my initial emails on this 
thread when the stacked devices topic came up.
Since there was reluctance in introducing a switch device (theThing), My 
current patch tries to do that without a switch device.
Since this is still l2, and we are dealing with bridge port attributes, 
my current patch traverses the stacked netdevs to call the 
ndo_bridge_setlink on the switch port.

When it comes to l3, we can follow the same.., but as discussed in Du, 
there are other reasons where a switch device becomes necessary.
I can submit an alternate series to cover the switch device approach for 
l2 as well.

Thanks,
Roopa
