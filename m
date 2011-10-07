From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Fri, 07 Oct 2011 09:44:07 -0700
Message-ID: <4E8F2C57.5020600@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com>  <1317846693.3457.11.camel@edumazet-laptop>  <4E8CC474.7050803@candelatech.com>  <1317850603.3457.21.camel@edumazet-laptop>  <4E8CD180.5010905@candelatech.com>  <4E8CDB9B.6010900@candelatech.com> <1317932911.3457.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34779 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab1JGQoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:44:09 -0400
In-Reply-To: <1317932911.3457.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2011 01:28 PM, Eric Dumazet wrote:
> Le mercredi 05 octobre 2011 =C3=A0 15:35 -0700, Ben Greear a =C3=A9cr=
it :
>
>> If someone wants to cook up macvlan-ip-defrag patch I'll be happy
>> to test it.  But, as far as I can tell, this problem can happen on
>> any two interfaces.  The reason that some of mine work (.1q vlans)
>> and macvlan didn't is probably because those were separated by
>> some virtual network links that imparted extra delay...so the
>> vlan consumed all its fragments and passed the complete pkt up
>> the stack before the mac-vlan ever saw the initial frame.
>>
>> With this in mind, it seems that using multiple udp multicast
>> sockets bound to specific devices is fundamentally broken for
>> fragmented packets.
>>
>> I have no pressing need for this feature, so now that I better under=
stand
>> the problem I can just document it and move on to other things.
>>
>> Thanks for all the help.
>>
>
> Please test following patch (note I had no time to test it, sorry !)

I hope to test this soon, but lots of other things piled up all
at once, so might be a few days.

Thanks,
Ben

>
> Based on net-next tree, might apply on 3.0 kernel...
>
> [PATCH net-next] macvlan: handle fragmented multicast frames
>
> Fragmented multicast frames are delivered to a single macvlan port,
> because ip defrag logic considers other samples are redundant.
>
> Implement a defrag step before trying to send the multicast frame.


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
