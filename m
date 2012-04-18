From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: Occassional death on 3.3
Date: Tue, 17 Apr 2012 17:55:11 -0700
Message-ID: <20120418005511.GA2944@mcarlson.broadcom.com>
References: <CAKb7UvjWACB5wF9B1GvznVd64Vby_9ri4SMo57RpAhrhf+awFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org
To: "Ilia Mirkin" <imirkin@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2211 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740Ab2DRAzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 20:55:44 -0400
In-Reply-To: <CAKb7UvjWACB5wF9B1GvznVd64Vby_9ri4SMo57RpAhrhf+awFg@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 08:22:31PM -0400, Ilia Mirkin wrote:
> Hello,
> 
> I'm observing an issue where it appears that tg3 gets wedged into a
> bad state every so often, and never recovers. Doing a sequence of
> 
> ifconfig eth0 down
> rmmod broadcom
> rmmod tg3
> 
> modprobe broadcom
> modprobe tg3
> 
> Makes everything work again. The card I have:
> 
> 03:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink
> BCM57788 Gigabit Ethernet PCIe [14e4:1691] (rev 01)
>         Subsystem: Dell XPS 8300 [1028:04aa]
>         Flags: bus master, fast devsel, latency 0, IRQ 45
>         Memory at fb100000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [48] Power Management version 3
>         Capabilities: [60] Vendor Specific Information: Len=6c <?>
>         Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Capabilities: [cc] Express Endpoint, MSI 00
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [13c] Virtual Channel
>         Capabilities: [160] Device Serial Number [the mac address]
>         Capabilities: [16c] Power Budgeting <?>
>         Kernel driver in use: tg3
>         Kernel modules: tg3
> 
> I'm attaching the log for the full data dump, since my mailer will
> wrap it horribly otherwise, but the interesting lines are:
> 
> [2234380.228971] tg3 0000:03:00.0: eth0: transmit timed out, resetting
> ... some kind of data dump ...
> [2234382.216682] tg3 0000:03:00.0: eth0: 0: Host status block
> [00000001:00000080:(0000:01ef:0000):(01ef:00b2)]
> [2234382.216685] tg3 0000:03:00.0: eth0: 0: NAPI info
> [00000080:00000080:(00cb:00b2:01ff):01ef:(00b7:0000:0000:0000)]
> [2234382.319550] tg3 0000:03:00.0: tg3_stop_block timed out, ofs=1400
> enable_bit=2
> [2234382.421931] tg3 0000:03:00.0: tg3_stop_block timed out, ofs=c00
> enable_bit=2
> [2234382.427199] tg3 0000:03:00.0: eth0: Link is down
> [2234382.438168] tg3 0000:03:00.0: eth0: Link is down
> 
> Any further attempts to use the NIC, like ifconfig down/up result in a
> similar error log sequence happening. Also, while it's happening, the
> computer feels extremely laggy for a short period of time (~1s),
> leading me to believe it's doing an uninterruptible sleep of some kind
> going on.
> 
> This has happened twice, and at least the second time, there was no
> unusual traffic on the network. It's linked at 100M, and was probably
> doing 10K/s at most when the error happened. If this is insufficient
> information, please let me know what I should collect next time this
> might happen.
> 
> Thanks,

Thanks for the report Ilia.  I'm guessing the lag is coming from the
driver as it logs the register dump to the syslog.

The register dump shows that interrupts are enabled, but the tag value in
the interrupt mailbox register doesn't match the value in the status block
or the driver's private tag value.  I'll see where that leads me.

Stay tuned.
