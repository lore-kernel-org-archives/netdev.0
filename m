From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Thu, 08 Aug 2013 12:43:34 -0700
Message-ID: <5203F4E6.1010701@candelatech.com>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>   <1375920752.4004.71.camel@edumazet-glaptop>   <5202E510.9060309@candelatech.com>  <1375924125.4004.83.camel@edumazet-glaptop>  <5202FA51.4040906@candelatech.com> <1375930325.4004.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39648 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965983Ab3HHTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 15:43:35 -0400
In-Reply-To: <1375930325.4004.88.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 07:52 PM, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 18:54 -0700, Ben Greear wrote:
>
>> Maybe we should just do the csum calc in the kernel if packet is
>> about to be sent up to user-space via af_packet?  I think that
>> would keep the expected behaviour, and hopefully not loose any of the performance
>> benefits for cases where the packet never leaves the kernel?
>
> I think you are rephrasing what I suggested ;)
>
> I'll send a patch asap, unless someone beats me.


I'll be happy to test.

And a slightly related question if you have the time:

My kernel-mode bridge was breaking as well, but this appears to
be a bug in my code.  I had this code (since 2009, at least):

// Evidently this fixes issues with sending between NICs
// that support and do not support hw-csum.
skb->ip_summed = CHECKSUM_NONE;


It seems that at some point, this fixed some problem I saw, but it was long
ago.  If I remove this, then the 3.9 kernel bridges just fine between
the VETH and a physical interface.

I do not see any modification of the ip_summed in the bridge code.

So, the question is:  Is there any time that I *should* be mucking with
skb->ip_summed when bridging pkts from one device to another on modern
kernels?  I'm using the ptype_all hook to grab packets, and ndo_start_xmit
to send them, in case that matters.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
