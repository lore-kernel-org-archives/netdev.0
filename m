From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Mon, 10 Oct 2011 09:27:24 -0700
Message-ID: <4E931CEC.5050404@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com>  <1317846693.3457.11.camel@edumazet-laptop>  <4E8CC474.7050803@candelatech.com>  <1317850603.3457.21.camel@edumazet-laptop>  <4E8CD180.5010905@candelatech.com>  <4E8CDB9B.6010900@candelatech.com> <1317932911.3457.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51305 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab1JJQ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:27:27 -0400
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
>
> Based on net-next tree, might apply on 3.0 kernel...
>
> [PATCH net-next] macvlan: handle fragmented multicast frames
>
> Fragmented multicast frames are delivered to a single macvlan port,
> because ip defrag logic considers other samples are redundant.
>
> Implement a defrag step before trying to send the multicast frame.

I applied this to Linus' top-of-tree this morning and it does appear
to fix the problem for mac-vlans.

I do see this error, but I doubt it has anything to do with your
patch:

device eth0 entered promiscuous mode
device rddVR10 entered promiscuous mode
ADDRCONF(NETDEV_CHANGE): rddVR1b: link becomes ready

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ BUG: lock held when returning to user space! ]
------------------------------------------------
ip/3452 is leaving the kernel with locks still held!
1 lock held by ip/3452:
  #0:  (rcu_read_lock){.+.+..}, at: [<f8c5336f>] rcu_read_lock+0x0/0x26=
 [ipv6]
ADDRCONF(NETDEV_CHANGE): rddVR4b: link becomes ready
ADDRCONF(NETDEV_CHANGE): rddVR5b: link becomes ready


I have no idea why it doesn't print out a more useful stack
trace.  It seems repeatable (2 of 2 reboots so far).  I'm
configuring a pretty complex virtual network, with veth devices,
xorp instances running ipv4 and ipv6 routing protocols, etc.

This is a clean upstream kernel with no outside patches aside from your
own.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
