From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 07:27:23 -0800
Message-ID: <1456759643.648.65.camel@edumazet-ThinkPad-T530>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D45DAF.5070709@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On lun., 2016-02-29 at 07:03 -0800, Peter Hurley wrote:

> The reason why Eric's change is so effective for Eric's workload is
> that it fixes the problem where NET_RX keeps getting new network packets
> so it keeps looping, servicing more NET_RX softirq.

You have very little idea of what is happening in networking land.

Once hard irq for RX has triggered, we arm a NAPI (NET_RX softirq), and
no more irq will come unless the napi handler ran. Then when NAPI is
complete, we re-allow interrupt to be delivered when a new packet is
coming.

Yes, ksoftirqd runs under load, and this is _wanted_.

Sure, it might add a latency if some high prio task is wanting the same
cpu, but this is exactly the purpose of having multi tasking.
