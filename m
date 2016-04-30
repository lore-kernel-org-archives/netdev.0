From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?B?ZG9u4oCZdCBtb2RpZnkgaXBf?=
 =?UTF-8?B?c3VtbWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3M=?=
 =?UTF-8?B?dW1zIGFzIGdvb2Qu?=
Date: Sat, 30 Apr 2016 13:59:31 -0700
Message-ID: <57251CB3.1040504@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk>	<5720E1F0.9010203@candelatech.com>	<1461780469.5102.0.camel@decadent.org.uk>	<1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>	<572155F4.10405@candelatech.com>	<20160428102953.GA7656@bistromath.localdomain>	<1462041181.17662.3.camel@decadent.org.uk>	<57250A17.5090804@candelatech.com> <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55475 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbcD3U7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 16:59:35 -0400
In-Reply-To: <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/30/2016 12:54 PM, Tom Herbert wrote:
> We've put considerable effort into cleaning up the checksum interface
> to make it as unambiguous as possible, please be very careful to
> follow it. Broken checksum processing is really hard to detect and
> debug.
>
> CHECKSUM_UNNECESSARY means that some number of _specific_ checksums
> (indicated by csum_level) have been verified to be correct in a
> packet. Blindly promoting CHECKSUM_NONE to CHECKSUM_UNNECESSARY is
> never right. If CHECKSUM_UNNECESSARY is set in such a manner but the
> checksum it would refer to has not been verified and is incorrect this
> is a major bug.

Suppose I know that the packet received on a packet-socket has
already been verified by a NIC that supports hardware checksumming.

Then, I want to transmit it on a veth interface using a second
packet socket.  I do not want veth to recalculate the checksum on
transmit, nor to validate it on the peer veth on receive, because I do
not want to waste the CPU cycles.  I am assuming that my app is not
accidentally corrupting frames, so the checksum can never be bad.

How should the checksumming be configured for the packets going into
the packet-socket from user-space?

Also, I might want to send raw frames that do have
broken checksums (lets assume a real NIC, not veth), and I want them
to hit the wire with those bad checksums.

How do I configure the checksumming in this case?


Thanks,
Ben


>
> Tom
>
> On Sat, Apr 30, 2016 at 12:40 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>> On 04/30/2016 11:33 AM, Ben Hutchings wrote:
>>>
>>> On Thu, 2016-04-28 at 12:29 +0200, Sabrina Dubroca wrote:
>>>>
>>>> Hello,
>>
>>
>>>>>
>>>>> http://dmz2.candelatech.com/?p=linux-4.4.dev.y/.git;a=commitdiff;h=8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=454b07405d694dad52e7f41af5816eed0190da8a
>>>>
>>>> Actually, no, this is not really a regression.
>>>
>>> [...]
>>>
>>> It really is.  Even though the old behaviour was a bug (raw packets
>>> should not be changed), if there are real applications that depend on
>>> that then we have to keep those applications working somehow.
>>
>>
>> To be honest, I fail to see why the old behaviour is a bug when sending
>> raw packets from user-space.  If raw packets should not be changed, then
>> we need some way to specify what the checksum setting is to begin with,
>> otherwise, user-space has not enough control.
>>
>> A socket option for new programs, and sysctl configurable defaults for raw
>> sockets
>> for old binary programs would be sufficient I think.
>>
>>
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear <greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
>

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
