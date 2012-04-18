From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 10:30:12 -0700
Message-ID: <4F8EFA24.8020909@hp.com>
References: <1334653608.6226.11.camel@edumazet-laptop> <1334654187.2696.2.camel@jtkirshe-mobl>  <4F8D93E1.9090000@intel.com> <1334681204.2472.41.camel@edumazet-glaptop> <1334698722.2472.71.camel@edumazet-glaptop> <1334764184.2472.299.camel@edumazet-glaptop>  <4F8EF317.10504@hp.com> <1334769375.2472.310.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:9446 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab2DRRaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:30:13 -0400
In-Reply-To: <1334769375.2472.310.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2012 10:16 AM, Eric Dumazet wrote:
> On Wed, 2012-04-18 at 10:00 -0700, Rick Jones wrote:
>
>> Is the issue completely sent, or transmit completion processed?  I'd
>> think it is time to the latter that matters (and includes the former) yes?
>>
>
> I dont know. Fact is we process ACKs before clone skb is freed by TX
> completion.
>
>> Does the ixgbe driver do transmit completions first when it gets a
>> receive interrupt, or is there still the chance that the receipt of the
>> last ACK for the 64KB skb will hit TCP before the driver has done the
>> free?  (Or does that not matter?)
>
> It does transmit completions first, but that doesnt matter, since we
> receive ACK before skb could be drained by NIC and returned to driver
> for TX completion.

I was thinking more about the race if any between the ACK for the last 
byte of the 64 KB skb and the transmit completion processing freeing it 
in the driver.  But that may be moot.


>>> Performance results on my Q6600 cpu and 82599EB 10-Gigabit card :
>>> About 3% less cpu used for same workload (single netperf TCP_STREAM),
>>> bounded by x4 PCI-e slots (4660 Mbits).
>>
>> Three percent less or three percentage points less?  Including the
>> details of the netperf-reported service demand would make that clear.
>
> netperf results are not precise enough, since my setup is limited by PCI
> bandwidth. here are the "perf stat" ones

I'm confused -  Netperf's CPU utilization measurements (-c -C) and by 
extension service demand calculation should be able to see an overall 
three percentage point change in CPU util, even a three percent one.

>
> Maybe someone can run the test on 20Gb/40Gb links, and NUMA machine.
>
> Before patch :
>
> # perf stat -r 5 -d -d -o RES.before taskset 1 netperf -H 192.168.99.1 -l 20

I'm still learning about perf, and the manpage I have for it does not 
discuss the -d option but is that doing system wide, or only in the 
context of the netperf process?

rick
