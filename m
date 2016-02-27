From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sat, 27 Feb 2016 15:33:58 -0800
Message-ID: <56D23266.2080306@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456604037.648.29.camel@edumazet-ThinkPad-T530>
 <56D20733.1000409@hurleysoftware.com>
 <20160227.180403.2101360385050644823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmaengine@vger.kernel.org,
	john.ogness@linutronix.de, bigeasy@linutronix.de,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160227.180403.2101360385050644823.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2016 03:04 PM, David Miller wrote:
> From: Peter Hurley <peter@hurleysoftware.com>
> Date: Sat, 27 Feb 2016 12:29:39 -0800
> 
>> Not really. softirq raised from interrupt context will always execute
>> on this cpu and not in ksoftirqd, unless load forces softirq loop abort.
> 
> That guarantee never was specified.

??

Neither is running network socket servers at normal priority as if they're
higher priority than softirq.


> Or are you saying that by design, on a system under load, your UART
> will not function properly?
> 
> Surely you don't mean that.

No, that's not what I mean.

What I mean is that bypassing the entire SOFTIRQ priority so that
sshd can process one network packet makes a mockery of the point of softirq.

This hack to workaround NET_RX looping over-and-over-and-over affects every
subsystem, not just one uart.

HI, TIMER, BLOCK; all of these are skipped: that's straight-up, a bug.

Regards,
Peter Hurley
