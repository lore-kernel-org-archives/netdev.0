From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 07:19:13 -0800
Message-ID: <1456759153.648.61.camel@edumazet-ThinkPad-T530>
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

> Not the case. The softirq is raised from interrupt.
> 
> Before Eric's change, when an interrupt raises a new softirq
> while processing another softirq, the new softirq is immediately
> processed *after the existing softirq completes*.
> 
> After Eric's change, when an interrupt raises a new softirq
> while processing another softirq and _that softirq wakes a process_,
> the new softirq is *deferred to normal process priority*.

For the last time, this is not true.

My patch changed the probability for this to happen.

It will happen even if you revert it.

linux never claimed that softirq could steal all cpu time.

Are by any chance still running a HZ=100 kernel ?
