From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 8 Dec 2015 09:23:39 -0500
Message-ID: <5666E7EB.40709@mojatatu.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net>
 <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
 <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
 <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
 <20151201154445.GF29497@tuxdriver.com>
 <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
 <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
 <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
 <566687DC.7040805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35465 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbbLHOXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 09:23:43 -0500
Received: by igl9 with SMTP id 9so96861779igl.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 06:23:42 -0800 (PST)
In-Reply-To: <566687DC.7040805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-08 02:33 AM, John Fastabend wrote:
> On 15-12-02 04:15 PM, Tom Herbert wrote:

>>>
>>> Just keying off the last statement there...
>>>
>>> I think BPF programs are going to be hard to translate into hardware
>>> for most devices. The problem is the BPF programs in general lack
>>> structure. A parse graph would be much more friendly for hardware or
>>> at minimum the BPF program would need to be a some sort of
>>> well-structured program so a driver could turn that into a parse graph.
>>>
>> This might be relevant:
>> http://richard.systems/research/pdf/IEEE_HPSR_BPF_OPENFLOW.pdf
>>
>
> Thanks Tom interesting read but they seem to argue for a BPF engine in
> hardware which I'm still not convinced is necessary and the numbers
> provided are for a 1Gbps link where 10Gpbs/100Gbps+ would be more
> valuable.
>
> I am still leaning towards a fully programmable parse graph and a set
> of basic actions push/pop/set/fwd/etc. This would be useful for other
> features not just checksum offloads. I guess it doesn't necessarily
> exclude also having 1s complement logic though.


;-> I feel a little vindicated with this discussion.

Of course you can implement hardware using BPF! I think there is an
opportunity for someone to build such hardware, if one is not in
progress of being built yet.
A BPF hardware implementation is just a very different approach;
instead of it being a series of TCAM table hardware implementation
(and/or other  types of implementation which use DRAM etc), it becomes
CPU instructions. Surely one can cast the EBPF bytecode into an ASIC.
My disagreement with Tom is laying a stake that this is how hardware
features are to be exposed.
My disagreement with you is laying a stake in the ground that hardware
oughta be implemented using a series of Tubes^WTCAMS.
When i build a graphics card the API is not how the internal 
implementation works. Everbody conforms to the same driver APIs.
Likewise, we have Linux APIs - and switchdev
is the right direction. Write your driver to switchdev interfaces.
Let a thousand flowers bloom.

BTW: It is bordering on the abstraction-ridiculous when I see the
P4 claims to use ebpf and then somehow translate to use
classifier/actions.


cheers,
jamal
