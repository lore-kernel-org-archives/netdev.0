From: Alex Rosenbaum <alexr@mellanox.com>
Subject: Re: [PATCH v4 net-next 0/4] net: low latency Ethernet device polling
Date: Thu, 23 May 2013 14:00:35 +0300
Message-ID: <519DF6D3.40705@mellanox.com>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliezer,

With AmirV's help we got this working on our NIC as well and it look 
nice. We too see the nice performance gain.

I tested with epoll and as expected there is no performance improvement. 
I don't think there is any point delaying this feature commit due to 
this fact. Future development should handle that.

I also tested LLS with different message rates.
Using sockperf you can set a ping send rate (--msp) and measure latency 
at different rates (I don't think netperf can do this).
In the financial trading sector, low latencies for 100mps are just as 
important as in 50Kmsp (or higher). The market orders go out at these 
low rates.
I noticed a penalty in the latency performance as I go lower in mps. I 
don't think it is related to the LLS code but it is more obvious then 
without it since you reach lower results.

These numbers are for sockperf TCP ping-pong at different msp for a 12 
byte payload.
I verified LLS hit counter was at 100% for all different message rates 
on both server and client side.
Machine is a x86_64 Intel(R) Xeon(R) CPU E5-2620 0 @ 2.00GHz with 64GB ram.

    rate   | LLS-on RTT | LLS-off RTT
   (msp) |    (usec)      |   (usec)
  10000 |     14.0        |     21.8
    1000 |     15.6        |     23.0
      100 |     16.6        |     24.4

You can see that as I go lower in send message rate the latency increases.

* Don't consider these number as best results, they or on a random 
machine with some effort tuning and core isolation. I saw this hit in 
performance as lower the msg rate on several machine elsewhere and I am 
sure it will reproduce on your tuned machine so you can notice it as well.

Again, this should not block your feature commit but is interesting for 
me to understand and I though someone here might have a good explanation.

thanks,
Alex Rosenbaum
Director R&D Application Acceleration
Mellanox Technologies | Raanana, Israel | +972 (74) 712-9215
