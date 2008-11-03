From: Patrick McHardy <kaber@trash.net>
Subject: Re: New filter 'flow' bug?
Date: Mon, 03 Nov 2008 13:02:59 +0100
Message-ID: <490EE873.6040305@trash.net>
References: <20081030093953.4517510BFA8@f30.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: almaop@poczta.fm
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081030093953.4517510BFA8@f30.poczta.interia.pl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

almaop@poczta.fm wrote:
>> almaop@poczta.fm wrote:
>>>>> From: almaop@poczta.fm
>>>>>> I'm not sure where is the bug - in the flow filter or in the sfq
>>>> qdisc.
>>>>
>>>> Which SFQ qdisc is stalling?
>>>>
>>> Thanks for reply.
>>> So I've done few tests. I've removed quantum 64 (it  was qdisc with
>> small packets). It made no difference. It looks like the key is the first
>> sfq qdisc (tc qdisc add dev $DEV parent 1:2 handle 2: sfq - in my example).
>> When there is no traffic in this qdisc for about 45 seconds (shorter time
>> when there is no traffic at all on the interface) - it stalls. Other qdiscs
>> stall also. So there is no packet flow on that interface. Removing filters
>> ('flow' filters) does'nt help. I have to remove (all) sfq qdiscs. And then
>> the traffic is resumed.
>>
>> Please capture the output of "tc -s -d qdisc show dev <dev>" and
>> "tc -s -d class show dev <dev>" immediately after it stalls.
>> I'm interested in the amount of bytes/packets queued at the moment.
>>
> 
> I've captured it eve
> It looks like this:
> Example 1:
> 
> ...

In both cases there are no packets queued, so its not the qdiscs
which are stalling. My shot in the dark is  is that your classifier
rules are incorrect and don't handle ARP packets.
