From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?B?ZG9u4oCZdCBtb2RpZnkgaXBf?=
 =?UTF-8?B?c3VtbWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3M=?=
 =?UTF-8?B?dW1zIGFzIGdvb2Qu?=
Date: Thu, 28 Apr 2016 06:45:50 -0700
Message-ID: <5722140E.80702@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk> <5720E1F0.9010203@candelatech.com> <1461780469.5102.0.camel@decadent.org.uk> <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com> <572155F4.10405@candelatech.com> <20160428102953.GA7656@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	xiyou.wangcong@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160428102953.GA7656@bistromath.localdomain>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/28/2016 03:29 AM, Sabrina Dubroca wrote:
> Hello,
>
> 2016-04-27, 17:14:44 -0700, Ben Greear wrote:
>> On 04/27/2016 05:00 PM, Hannes Frederic Sowa wrote:
>>> Hi Ben,
>>>
>>> On Wed, Apr 27, 2016, at 20:07, Ben Hutchings wrote:
>>>> On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
>>>>> On 04/26/2016 04:02 PM, Ben Hutchings wrote:
>>>>>>
>>>>>> 3.2.80-rc1 review patch.  If anyone has any objections, please let me know.
>>>>> I would be careful about this.  It causes regressions when sending
>>>>> PACKET_SOCKET buffers from user-space to veth devices.
>>>>>
>>>>> There was a proposed upstream fix for the regression, but it has not gone
>>>>> into the tree as far as I know.
>>>>>
>>>>> http://www.spinics.net/lists/netdev/msg370436.html
>>>> [...]
>>>>
>>>> OK, I'll drop this for now.
>>>
>>> The fall out from not having this patch is in my opinion a bigger
>>> fallout than not having this patch. This patch fixes silent data
>>> corruption vs. the problem Ben Greear is talking about, which might not
>>> be that a common usage.
>>>
>>> What do others think?
>>>
>>> Bye,
>>> Hannes
>>>
>>
>> This patch from Cong Wang seems to fix the regression for me, I think it should be added and
>> tested in the main tree, and then apply them to stable as a pair.
>>
>> http://dmz2.candelatech.com/?p=linux-4.4.dev.y/.git;a=commitdiff;h=8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=454b07405d694dad52e7f41af5816eed0190da8a
>
> Actually, no, this is not really a regression.
>
> If you capture packets on a device with checksum offloading enabled,
> the TCP/UDP checksum isn't filled.  veth also behaves that way.  What
> the "veth: don't modify ip_summed" patch does is enable proper
> checksum validation on veth.  This really was a bug in veth.
>
> Cong's patch would also break cases where we choose to inject packets
> with invalid checksums, and they would now be accepted as correct.
>
> Your use case is invalid, it just happened to work because of a
> bug.  If you want the stack to fill checksums so that you want capture
> and reinject packets, you have to disable checksum offloading (or
> compute the checksum yourself in userspace).

Disabling checksum offloading or computing in user-space (and then
recomputing in veth to verify the checksum?) is a huge performance loss.

Maybe we could add a socket option to enable Cong's patch on a per-socket
basis?  That way my use-case can still work and you can have this new
behaviour by default?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
