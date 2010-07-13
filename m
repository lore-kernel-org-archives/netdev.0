From: Wolfgang Grandegger <wg@grandegger.com>
Subject: High process latencies due to MPC5200 FEC hard- soft-irq processing
Date: Tue, 13 Jul 2010 15:29:08 +0200
Message-ID: <4C3C6A24.3000906@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

we realized, that multiple ping floods (ping -f) can cause very large
high-priority process latencies (up to a many seconds) on a MPC5200
PowerPC system with FEC NAPI support. The latencies are measured with

  # cyclictest -p 80 -n

The problem is that processing of the ICMP pakets in the Hard-Irq and
Soft-IRQ context can last for a long time without returning to the
scheduler. Reducing MAX_SOFTIRQ_RESTART from 10 to 2 helps - the latency
goes down to 35 ms with 2 "ping -f" - but it's not a configurable
parameter, even if it somehow depends on the CPU power. And using the
-rt patches seems overkill to me. Any other ideas or comments on how to
get rid of such high process latencies?

Wolfgang.
