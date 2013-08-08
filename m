From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 18:54:25 -0700
Message-ID: <5202FA51.4040906@candelatech.com>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>  <1375920752.4004.71.camel@edumazet-glaptop>  <5202E510.9060309@candelatech.com> <1375924125.4004.83.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57309 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757239Ab3HHByl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 21:54:41 -0400
In-Reply-To: <1375924125.4004.83.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 06:08 PM, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 17:23 -0700, Ben Greear wrote:
>
>> I am receiving the packet into user space by reading veth2
>> using a packet socket, and then writing that packet out to eth6
>> (e100e).  As far as I can tell, it reads from veth2 with bad checksum
>> and then goes onto the wire with bad checksum.
>>
>
> Then, when you read the packet socket, you probably have an indication
> that checksum is to be computed or ignored.

My user-space bridge code doesn't know or care about the checksum, it
is just reading a packet from one interface and writing onto another.

>
> Your application breaks because of this.

>> Is it ever valid to *read* a packet with bad checksum though?  I thought
>> the bogus bad hw-checksum issue was only on the tx-side as far as sniffing goes?
>
> We have same flags on loopback interface.
>
> So using your application on loopback should break the same ?

I suppose, I have never tried to bridge loopback, and probably won't
try anytime soon.

> I am not saying your application is buggy, maybe we need a helper in
> net/packet/af_packet.c. Please check TP_STATUS_CSUMNOTREADY
>
> This was added 6 years ago in commit 8dc4194474159660
> ("[PACKET]: Add optional checksum computation for recvmsg")

Hmm, I'm using recmmsg, in case that matters.  I'm not sure I really
understand that patch well.  It looks like it requires user-space changes?

I'd rather not have to deal with calculating checksums just to bridge
two interfaces...if it comes to that, I'd rather just force a disable
of the HW checksum feature using ethtool when my app is configured in
this manner.

Maybe we should just do the csum calc in the kernel if packet is
about to be sent up to user-space via af_packet?  I think that
would keep the expected behaviour, and hopefully not loose any of the performance
benefits for cases where the packet never leaves the kernel?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
