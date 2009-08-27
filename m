From: H M Thalib <hmthalib@gmail.com>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Thu, 27 Aug 2009 21:08:25 +0530
Message-ID: <4A96A871.3090002@gmail.com>
References: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20090819145057.GA25400@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


Johannes Stezenbach wrote:
> Hi,
> 
> a while ago I was working on a SoC with 200MHz ARM926EJ-S CPU
> and integrated 100Mbit ethernet core, connected on internal
> (fast) memory bus, with DMA.  With iperf I measured:
> 

Did you used Iperf it is not the correct tool to find the performance of 
ethernet. use tools like Smartbits or IXIA they are special hardware to 
measure the performance . They will give you better results

>   TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
>   TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)

Did you stopped unwanted process in both PC as well as processor, make 
sure PC has a bottle neck. Does it gives a through put of at least 
95MBps. Is you system connected directly with crossover cables.

> The CPU load during the iperf test is around
> 1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.

Did you used vmast -- it is not the correct way to measure the cpu load
or do you use top -- it takes lots of you system resource .. this can 
affect ehternet performance

> The kernel used in these measurements does not have iptables
> support, I think packet filtering will slow it down noticably,
> but I didn't actually try.

Thats good. iptable will dramatically affect the performance. remove all 
the iptables related modules if it is loaded before performing test

   The ethernet driver uses NAPI,
> but it doesn't seem to be a win judging from the irq/sec number.
> The kernel was an ancient 2.6.20.
> 
not bad. worth upgrading.

> I tried hard, but I couldn't find any performance figures for
> comparison.  (All performance figures I found refer to 1Gbit
> or 10Gbit server type systems.)

surely you will not find the perf data for small low end processor 
because they are not made fro that. and also this data is not some thing 
sharable .they are the benchmark about their product.

Industry is interested in high performance processor for network 
product. beside ethernet they do have lot offloading engines.

> What I'm interested in are some numbers for similar hardware,
> to find out if my hardware and/or ethernet driver can be improved,
> or if the CPU will always be the limiting factor.

probably should be possible optimizing hardware+software but you have to 
   pay for that.

> I'd also be interested to know if hardware checksumming
> support would improve throughput noticably in such a system,
> or if it is only useful for 1Gbit and above.

In my experience for your cpu 80% max of ehternet speed should be ok .. 
don't expect more.

> 
> Did anyone actually manage to get close to 100Mbit/sec
> with similar CPU resources?
> 
> 
> TIA,
> Johannes
> --
> To unsubscribe from this list: send the line "unsubscribe linux-embedded" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Thanks & Regards,
H M Thalib.
