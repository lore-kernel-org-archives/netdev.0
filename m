From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Thu, 08 Aug 2013 15:35:44 -0700
Message-ID: <52041D40.8060609@candelatech.com>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>     <1375920752.4004.71.camel@edumazet-glaptop>     <5202E510.9060309@candelatech.com>    <1375924125.4004.83.camel@edumazet-glaptop>    <5202FA51.4040906@candelatech.com>   <1375930325.4004.88.camel@edumazet-glaptop>   <5203F4E6.1010701@candelatech.com>  <1375993014.4004.112.camel@edumazet-glaptop>  <52041802.9040304@candelatech.com> <1376000531.4004.136.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36632 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966767Ab3HHWfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 18:35:45 -0400
In-Reply-To: <1376000531.4004.136.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 03:22 PM, Eric Dumazet wrote:
> On Thu, 2013-08-08 at 15:13 -0700, Ben Greear wrote:
>
>> Looks like it should work nicely, except it would be really
>> nice if I could short-circuit the xmit_nit() part for my
>> protocol handler.
>>
>> Think there would be any interest in allowing the ptype_all
>> handlers to optionally register a direction (ie tx-only, rx-only, both)
>> and have dev_queue_xmit_nit() pay attention to that?
>
> Sure, it would also make sense to apply the BPF filter _before_ doing
> the skb_clone()
>
> Right now, we :
>
> clone packets
> -> deliver the clone to the sniffer.
>   sniffer eventuall drops the packet after BPF filtering.
>
> Its trivial to test the tx/rx thing in BPF, and it's JIT code.

I'm actually registering the hook from a kernel module and
doing the bridging in this module.  I'm not using sockets or
BPF like a sniffer would...

I think for my own use, just causing the skb_loop_sk() method to
return true would be optimal, but in general I like your idea.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
