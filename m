From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Tue, 18 Sep 2007 12:44:46 -0400
Message-ID: <20070918124446.89100042.billfink@mindspring.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
	<ygfps0g8lj0.fsf@janus.isnogud.escape.de>
	<82k5qoxfbk.fsf@mid.bfk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"L F" <lfabio.linux@gmail.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: Florian Weimer <fweimer@bfk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:34610 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754203AbXIRQpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 12:45:04 -0400
In-Reply-To: <82k5qoxfbk.fsf@mid.bfk.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Sep 2007, Florian Weimer wrote:

> * Urs Thuermann:
> 
> > How can a corrupted frame pass the TCP checksum check?
> 
> The TCP/IP checksums are extremely weak.  If the corruption is due to
> defective SRAM or something like that, it's likely that it causes an
> error pattern which is 16-bit-aligned.  And an even number of
> 16-bit-aligned bit flips is not detected by the TCP checksum. 8-(
> 
> Actually, nobody should use TCP without application-level checksums
> for that reason.  But of course, there is HTTP.

But in this specific case, IIRC there were _no_ receive checksum
errors seen, and it would seem odd that any bit corruption was
_always_ an even number of 16-bit-aligned bit flips.

Also, I don't know anything at all about the SAMBA fs/protocol, but
I would expect it would have some kind of stronger data integrity
capability that should catch such errors.  Which would be another
reason implying the data corruption problem is above the network
layer, and perhaps a hardware error of some kind on the write path
to the disk (also could possibly be a software bug of some kind
in that path).

						-Bill
