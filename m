From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Wed, 8 Jan 2014 14:15:13 +0200
Message-ID: <52CD4151.9050100@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>		 <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>		 <1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>		 <CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>		 <1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>		 <CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com>	 <1389130693.26646.72.camel@edumazet-glaptop2.roam.corp.google.com>	 <52CD0686.4090205@mellanox.com> <1389182291.26646.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:60007 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755160AbaAHMP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 07:15:28 -0500
In-Reply-To: <1389182291.26646.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 13:58, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 10:04 +0200, Or Gerlitz wrote:
>> On 07/01/2014 23:38, Eric Dumazet wrote:
>>> On Tue, 2014-01-07 at 22:37 +0200, Or Gerlitz wrote:
>>>
>>>> So here's the thing, per my understanding we want to GRO only received
>>>> **encapsulated** packets whose checksum status is != CHECKSUM_NONE
>>>> which means the NIC has some support for doing RX checksum of
>>>> encapsulated packets. Per the current convension, in that case the NIC
>>>> RX code has to set skb->encapsulation see 6a674e9c75b17 "net: Add
>>>> support for hardware-offloaded encapsulation" this convension is
>>>> implemented in the current drivers that have HW offloads for
>>>> encapsulated packets (bnx2x, i40e and mlx4)
>>> I do not think its true.
>>>
>>> Some drivers set CHECKSUM_COMPLETE even for regular UDP frames...
>>>
>>> git grep -n CHECKSUM_COMPLETE -- drivers/net
>>>
>>>
>>>
>> Eric, the point I was trying to make is that as long as the driver set a
>> value which is different from CHECKSUM_NONE
>> for an skb who carry encapsulated packet, we want skb->encapsulation to
>> be set, per the architecture dictated by the above commit.
> Then this point is obviously wrong. Your interpretation is wrong, I am very sorry.
> skb->encapsulation _might_ be set, only if the NIC is performing header
> analysis. CHECKSUM_COMPLETE support doesn't require header analysis.
>
>
>
>
fair enough && thanks for shedding more light on this - so in that 
respect, the gro handler for udp encapsulated packets will not flush skb 
who is either marked with CHECKSUM_COMPLETE or has skb->encapsulation set.

Or.
