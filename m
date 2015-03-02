From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Flows! Offload them.
Date: Mon, 02 Mar 2015 08:45:21 -0500
Message-ID: <54F46971.4090302@mojatatu.com>
References: <20150226074214.GF2074@nanopsycho.orion>	<20150226083758.GA15139@vergenet.net>	<20150226091628.GA4059@nanopsycho.orion>	<20150226133326.GC23050@casper.infradead.org> <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com> <54EF3E45.3070103@intel.com> <54F0721E.1030703@mojatatu.com> <54F08BE1.1080200@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>
To: John Fastabend <john.r.fastabend@intel.com>,
	Shrijeet Mukherjee <shrijeet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33066 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbbCBNpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 08:45:25 -0500
Received: by igbhl2 with SMTP id hl2so15936457igb.0
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 05:45:24 -0800 (PST)
In-Reply-To: <54F08BE1.1080200@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On 02/27/15 10:23, John Fastabend wrote:
> On 02/27/2015 05:33 AM, Jamal Hadi Salim wrote:


>> tc filter add ingress ethx classifier foo priority X \
>> match xyz action redirect macvlan3 offload
>>
>> where "offload" sets the netlink or classifier specific instruction
>> to offload.
>>
>> You can easily map macvlan3 to vsi 3.
>>
>
> This is why I said if you want to map my "flow" tool onto "tc" it can
> be done. :) I made a jump from macvlans that have net device representations
> to VFs being assigned to user space (VMs) where there is no net device
> to "redirect" to. So my explanation wasn't clear. Couple additional notes,
>
> The only issue I have with your 'tc' case is the "ingress" qdisc is per port where
> my flow tool is scoped at the switch pipeline so I would modify your cmd
> slightly and use a new classifier hook,
>
>   tc filter add sw-pipeline ethx classifier flow priority X \
>      match xyz action redirect macvlan3 offload
>

For hardware, we are talking abstractions, no? i.e it doesnt have
to be 1-1 mapping. IOW, It shouldnt matter how the hardware table
looks like as long as the kernel abstractions work on it.
There are two hooks:
either ingress or egress. These can be expressed in the kernel via
policy. Most hardware supports either one or the other.
IOW, I think the expressability in software is sufficient. In the
h/ware you are referring to - it is ingress.

> The other thing to note is "redirect" to macvlan3 doesn't handle the case
> where the VF is direct assigned to a VM in this case we don't have a netdev
> in the hypervisor to "redirect" to. Using the VSI# allows the hardware
> to translate the redirect cmd to the VF.
>

I agree - this is an interesting exception from a policy expression
view.

> So one more slight tweak,
>
>   tc filter add sw-pipeline ethx classifier flow priority X \
>      match xyz action redirect vsi:2 offload
>
> use the "vsi:" prefix to indicate this is for a hardware mapped VSI this
> way the user can use what ever notion is more convenient.
>

we do need the namespace separation. The concept of a "netdev" that
exists in hardware but is hidden at the hypervisor level is something
that needs to be addressed. I am still in love with concept of
abstracting these things as netdevs.
The question is how do you map which "vsi:" to which netdev on which
VM?

cheers,
jamal
