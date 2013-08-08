From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Thu, 08 Aug 2013 15:20:23 -0700
Message-ID: <520419A7.8060704@candelatech.com>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>    <1375920752.4004.71.camel@edumazet-glaptop>    <5202E510.9060309@candelatech.com>   <1375924125.4004.83.camel@edumazet-glaptop>   <5202FA51.4040906@candelatech.com>  <1375930325.4004.88.camel@edumazet-glaptop>  <5203F4E6.1010701@candelatech.com> <1375993014.4004.112.camel@edumazet-glaptop> <52041802.9040304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60339 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966217Ab3HHWUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 18:20:24 -0400
In-Reply-To: <52041802.9040304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 03:13 PM, Ben Greear wrote:
> On 08/08/2013 01:16 PM, Eric Dumazet wrote:
>> On Thu, 2013-08-08 at 12:43 -0700, Ben Greear wrote:
>>
>>> So, the question is:  Is there any time that I *should* be mucking with
>>> skb->ip_summed when bridging pkts from one device to another on modern
>>> kernels?  I'm using the ptype_all hook to grab packets, and ndo_start_xmit
>>> to send them, in case that matters.
>>
>>
>> ndo_start_xmit() is likely bypassing the core network fallbacks.
>>
>> You might try dev_hard_start_xmit() instead
>
> Looks like it should work nicely, except it would be really
> nice if I could short-circuit the xmit_nit() part for my
> protocol handler.
>
> Think there would be any interest in allowing the ptype_all
> handlers to optionally register a direction (ie tx-only, rx-only, both)
> and have dev_queue_xmit_nit() pay attention to that?

Actually, seems I might be able to abuse the ptype->af_packet_priv
and skb->sk and make the xmit_nit() not pass it back up...

Still might be interesting to have direction support in the ptype
handlers though...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
