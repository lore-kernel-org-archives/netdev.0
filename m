From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] net: Correctly set segment mac_len in skb_segment().
Date: Fri, 01 Aug 2014 08:58:56 -0400
Message-ID: <53DB8F10.8090901@redhat.com>
References: <1406817186-17844-1-git-send-email-vyasevic@redhat.com> <20140731.222912.1916841568774711697.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbaHAM7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 08:59:00 -0400
In-Reply-To: <20140731.222912.1916841568774711697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 01:29 AM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Thu, 31 Jul 2014 10:33:06 -0400
> 
>> When performing segmentation, the mac_len value is copied right
>> out of the original skb.  However, this value is not always set correctly
>> (like when the packet is VLAN-tagged) and we'll end up copying a bad
>> value.
>>
>> One way to demonstrate this is to configure a VM which tags
>> packets internally and turn off VLAN acceleration on the forwarding
>> bridge port.  The packets show up corrupt like this:
>> 16:18:24.985548 52:54:00:ab:be:25 > 52:54:00:26:ce:a3, ethertype 802.1Q
>> (0x8100), length 1518: vlan 100, p 0, ethertype 0x05e0,
>>         0x0000:  8cdb 1c7c 8cdb 0064 4006 b59d 0a00 6402 ...|...d@.....d.
>>         0x0010:  0a00 6401 9e0d b441 0a5e 64ec 0330 14fa ..d....A.^d..0..
>>         0x0020:  29e3 01c9 f871 0000 0101 080a 000a e833)....q.........3
>>         0x0030:  000f 8c75 6e65 7470 6572 6600 6e65 7470 ...unetperf.netp
>>         0x0040:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
>>         0x0050:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
>>         0x0060:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
>>         ...
>>
>> This also leads to awful throughput as GSO packets are dropped and
>> cause retransmissions.
>>
>> The solution is to set the mac_len using the values already available
>> in then new skb.  We've already adjusted all of the header offset, so we
>> might as well correctly figure out the mac_len using skb_reset_mac_len().
>> After this change, packets are segmented correctly and performance
>> is restored.
>>
>> CC: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> Applied, and I'm assuming this is meant to go to -stable too right?
> 

yes, please.

Thanks
-vlad
