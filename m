From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: Re: GRO aggregation
Date: Wed, 12 Sep 2012 12:23:58 +0300
Message-ID: <505054AE.9040901@mellanox.com>
References: <504F4063.9030706@mellanox.com>  ,<1347388396.13103.658.camel@edumazet-glaptop>  <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>  ,<1347390113.13103.660.camel@edumazet-glaptop>  <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com> <1347392132.13103.663.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:40160 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752014Ab2ILJYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 05:24:11 -0400
In-Reply-To: <1347392132.13103.663.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/11/2012 10:35 PM, Eric Dumazet wrote:
> On Tue, 2012-09-11 at 19:24 +0000, Shlomo Pongratz wrote:
>
>> I see that in ixgbe the weight for the NAPI is 64 (netif_napi_add). So
>> if packets are arriving in high rate then an the CPU is fast enough to
>> collect the packets as they arrive, assuming packets continue to
>> arrives while the NAPI runs. Then it should have aggregate more. So we
>> will have less passes trough the stack.
>>
> As I said, _if_ your cpu was loaded by other stuff, then you would see
> biggest GRO packets.
>
> GRO is not : "We want to kill latency and have big packets just because
> its better"
>
> Its more like : If load is big enough, try to aggregate TCP frames in
> less skbs.
>
>
>
>
First I want to apologize for breaking the mailing thread. I wasn't at 
work and used webmail.

I agree with your but I think that something is still strange.
On the transmitter side all the offloading are enabled, e.g. TSO and GSO.
The tcpdump on the sender side shows size of 64240 which is 44 packets 
of 1460 each.
Now since the offloading are enabled the HW should transmit 44 frames 
back to back,
that is in a burst of 44 * 1500 bytes, which according to my calculation 
should take 52.8 micro on 10G Ethernet.
Using ethtool I've set the rx-usecs to 1022 micro, which I think is the 
maximal value for ixgbe.
Note that there is no way to set rx-frames on ixgbe.
Now since the ixgbe weight is 64 I expected that the NAPI will be able 
to poll for more then 21 packets,
since 44 packets came in one burst.
However the results remains the same.

Shlomo.
