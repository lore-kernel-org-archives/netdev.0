From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 1 Dec 2015 16:40:22 -0800
Message-ID: <565E3DF6.4050609@intel.com>
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
 <20151201160841.GG29497@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48880 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932273AbbLBAkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 19:40:23 -0500
In-Reply-To: <20151201160841.GG29497@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/1/2015 8:08 AM, John W. Linville wrote:
> On Tue, Dec 01, 2015 at 04:49:28PM +0100, Hannes Frederic Sowa wrote:
>> On Tue, Dec 1, 2015, at 16:44, John W. Linville wrote:
>>> On Mon, Nov 30, 2015 at 09:26:51PM -0800, Tom Herbert wrote:
>>>> On Mon, Nov 30, 2015 at 5:28 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>>> Based on what we can do today, I see only two real choices: do some
>>>>> refactoring to clean up the stack a bit or remove the existing VXLAN
>>>>> offloading altogether. I think this series is trying to do the former
>>>>> and the result is that the stack is cleaner after than before. That
>>>>> seems like a good thing.
>>>> There is a third choice which is to do nothing. Creating an
>>>> infrastructure that claims to "Generalize udp based tunnel offload"
>>>> but actually doesn't generalize the mechanism is nothing more than
>>>> window dressing-- this does nothing to help with the VXLAN to
>>>> VXLAN-GPE transition for instance. If geneve specific offload is
>>>> really needed now then that can be should with another ndo function,
>>>> or alternatively ntuple filter with a device specific action would at
>>>> least get the stack out of needing to be concerned with that.
>>>> Regardless, we will work optimize the rest of the stack for devices
>>>> that implement protocol agnostic mechanisms.
>>> Is there no concern about NDO proliferation? Does the size of the
>>> netdev_ops structure matter? Beyond that, I can see how a single
>>> entry point with an enum specifying the offload type isn't really any
>>> different in the grand scheme of things than having multiple NDOs,
>>> one per offload.
>>>
>>> Given the need to live with existing hardware offloads, I would lean
>>> toward a consolidated NDO. But if a different NDO per tunnel type is
>>> preferred, I can be satisified with that.
>> Having per-offloading NDOs helps the stack to gather further information
>> what kind of offloads the driver has even maybe without trying to call
>> down into the layer (just by comparing to NULL). Checking this inside
>> the driver offload function clearly does not have this feature. So we
>> finally can have "ip tunnel please-recommend-type" feature. :)
> That is a valuable insight! Maybe the per-offload NDO isn't such a
> bad idea afterall... :-)
>
> John
This helps me understand why having a separate ndo op might still be ok. 
Thanks for the feedback. I will go back to that model.  Also  I think I 
did finally understand the discussion on using a single 2's compliment 
checksum method
for future silicon.
