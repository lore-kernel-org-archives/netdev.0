From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Wed, 1 Oct 2003 07:40:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001074036.466ded68.rddunlap@osdl.org>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010124F0B1@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com,
        cramerj@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010124F0B1@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2003 01:19:41 -0700 "Feldman, Scott" <scott.feldman@intel.com> wrote:

| Chris can jump in here anytime.  :-)
| 
| Synchronizing on the hardware side is stumping me.  We have the list of
| skbs you describe, but I'm concerned about unmapping the skb buffers if
| hardware is right in the middle of some DMA  on one of the buffers.
| Some archs really don't like hardware accessing unmapped buffers.
| 
| Here's what I'm thinking: when link down is detected in the timer, just
| trick hardware into thinking link is still up (ILOS - Invert Loss of
| Signal).  No locking, no disabling of interrupts.  Hardware will do the
| natural thing by completing the outstanding sends and also provide the
| interrupts so we can clean/return skbs as normal (e1000_clean_tx_irq).
| Something like:
| 
| <timer>
| 	if lost link
| 		if outstanding Tx work
| 			set ILOS		// h/w thinks link is
| up, DMA continues
| 			mdelay(10)
| 			clear ILOS		// h/w thinks link is
| down
| 			
| The mdelay(10) is terrible, but we've already got that in the current
| tx_flush routine.
| 
| Chris, what am I missing?  I didn't included the ANE business for
| clarity.

What happens if the link comes back up (live) during the mdelay
period?  Tiny race?  Just a delay until it's corrected?

--
~Randy
