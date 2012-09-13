From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 09:36:49 +0300
Message-ID: <50517F01.9050501@mellanox.com>
References: <504F4063.9030706@mellanox.com>  , <1347388396.13103.658.camel@edumazet-glaptop> <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com> , <1347390113.13103.660.camel@edumazet-glaptop> <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com> <1347392132.13103.663.camel@edumazet-glaptop> <505054AE.9040901@mellanox.com> <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com> <5050B6FF.5050002@hp.com> <5050B9B2.5070107@mellanox.com> <5050BDB5.8090200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:36238 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750726Ab2IMGhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 02:37:17 -0400
In-Reply-To: <5050BDB5.8090200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/2012 7:52 PM, Rick Jones wrote:
> On 09/12/2012 09:34 AM, Shlomo Pongartz wrote:
>> On 9/12/2012 7:23 PM, Rick Jones wrote:
>>> On 09/12/2012 07:41 AM, Shlomo Pongartz wrote:
>>>> Hi Eric
>>>>
>>>> The TSO is just a mean to create a burst of frames on the wire so the
>>>> NAPI will be able to pool as much as possible.
>>>
>>> Is it?  If I recall correctly, TSO was in place well before all
>>> drivers were using NAPI.  And NAPI was being proposed independent of
>>> TSO. TSO is there to save CPU cycles on the transmit side. "On the
>>> wire" what it sends is to be identical to what a host with greater CPU
>>> performance could accomplish.
>>>
>>> rick jones
>>>
>> Hi Rick.
>>
>> What I say is that I use TSO on the machine that transmits so I'll have
>> a burst of frames on the wire for the NAPI on the receiver machine.
>
> Also, NAPI was in place before GRO.  IIRC, the napi code was simply a 
> convenient/correct/natural place to have the GRO functionality.
>
> rick jones
>
Hi Rick

The thing is that napi_complete calls napi_gro_flush so this pose a 
limit on the aggregation.
However when I count the number of packets received until this routine 
is been called, I get a number,
which is bigger then what I see with tcpdump, and this number is less 
than what is expected if the limit is 64K.
So I what to know what can I do in order to improve things, e.g. 
allocate the skb differently.

Shlomo
