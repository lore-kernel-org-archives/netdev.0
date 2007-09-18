From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Tue, 18 Sep 2007 04:47:02 -0400
Message-ID: <20070918044702.0b5db963.billfink@mindspring.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
	<ygfps0g8lj0.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"L F" <lfabio.linux@gmail.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:51957 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbXIRIr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 04:47:29 -0400
In-Reply-To: <ygfps0g8lj0.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 Sep 2007, Urs Thuermann wrote:

> Bill Fink <billfink@mindspring.com> writes:
> 
> > It may also be a useful test to disable hardware TSO support
> > via "ethtool -K ethX tso off".
> 
> All suggestions here on the list, i.e. checking for flow control,
> duplex, cable problems, etc. don't explain (at least to me) why LF
> sees file corruption.  How can a corrupted frame pass the TCP checksum
> check?  Does TCP use the hardware checksum of the NIC if available?
> AFAICS, this would be the only way for a corrupt frame to make it into
> the file.  But Bill already suggested this and LF reported that it
> didn't make a difference.
> 
> A few months ago I had hadware problems with an embedded device, where
> transmission from the NIC via the PCI bus to the CPU had some bits
> flipped.  But tcpdump clearly showed the TCP checksum errors and also
> TCP recognized the errors and the connection was stalled.  And, BTW,
> we also observed an increasing percentage of corrupted frames with
> increasing traffic on that interface, i.e. increasing load on the PCI
> bus.
> 
> So I would run tcpdump -s0 and watch for "incorrect checksum" messages.

I agree TSO is an unlikely candidate since it should only affect
transmits and the problem as I understand it is with receives.
But still one of the first things I try doing when dealing with
weird problems is disabling all hardware assists.

But I also agree with you that network errors should normally be
detected by the TCP checksum (unless hardware checksumming was
messed up), and from what I recall there were no receive checksum
errors being seen.  That and the fact that the problem was seen
with two different NICs would lead me to believe that the problem
is elsewhere in the system.

That leaves many possibilities.  It could be a memory problem,
although it was indicated that memory testing was successfully
performed (but we don't know how extensive the memory checking
is enabled via the BIOS).  It could be the PCI bus writes back
to the disk, or a problem with the disk/controller/fs writes
themselves (some kind of disk stress test might be useful).

						-Bill
