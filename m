From: Jerry Chu <hkchu@google.com>
Subject: Re: GRO: very bad routing performance with 3.14.4 for GRE-packets
Date: Tue, 8 Jul 2014 17:19:33 -0700
Message-ID: <CAPshTCgBRn6JT=b=anaoLxeAs1CfkiavuV4MRev+yeHo9VBddQ@mail.gmail.com>
References: <1442942.x8F4o95O8x@h2o.as.studentenwerk.mhn.de>
	<1404859475.3515.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Walter <linux@stwm.de>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:64254 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaGIATe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 20:19:34 -0400
Received: by mail-vc0-f169.google.com with SMTP id la4so6223390vcb.14
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 17:19:34 -0700 (PDT)
In-Reply-To: <1404859475.3515.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2014 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-07-08 at 22:35 +0200, Wolfgang Walter wrote:
>> Hello,
>>
>> I upgraded a router from 3.10.46 to 3.14.4 and I see a dramatic perfomance
>> loss for GRE-pakets if (and only if) GRO is enabled on the incoming or
>> outgoing interface (drops to 1/50th to 1/100th).
>>
>> Other traffic is just fine.
>>
>> The router itself is not endpoint of the GRE-tunnel.
>>
>> The router has connection tracking enabled and does NAT (but most of the
>> traffic is not NATed nor are GRE-packets).
>>
>> The network card is an Intel Corporation I350 Gigabit (both interfaces).
>>
>> Regards,
>
> GRO is a win if the consumer of the packets understands GSO packets.
>
> In this case, Intel driver is not able to send GSO packets with GRE
> encapsulation, so they need to be segmented before being sent.
>
> That's extra work and not worth it, as you noticed.
>
> One way to get good performance would be to implement a software TSO in
> the Intel driver for the GRE encapsulated packets.
>
> You might revert bf5a755f5e9186406bbf50f4087100af5bd68e40, or submit a
> patch to make the GRE handling in GRO an optional feature.
>

There is also a bug to the forwarding path introduced by my GRE-GRO
patch that I discovered a while back and submitted a fix to it. Please
see http://patchwork.ozlabs.org/patch/324953/ and let me know if that
addresses the problem you've seen. Sorry I have not got the time to
follow through with the patch.
