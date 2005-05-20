From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 16:45:04 -0700 (PDT)
Message-ID: <20050520.164504.31639000.davem@davemloft.net>
References: <20050520194220.GA18259@havoc.gtf.org>
	<20050520.152836.48528379.davem@davemloft.net>
	<428E72F9.3070404@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <428E72F9.3070404@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 20 May 2005 19:30:01 -0400

> Sure.  What I'm driving at is that a checksum of zero seems to imply 
> CHECKSUM_NONE not CHECKSUM_UNNECESSARY.  tg3 only does the 0xffff check.

Sure, both ways are fine.

> I am also a bit surprised that, if the actual checksum value is 
> available, why not use CHECKSUM_HW like sunhme?

CHECKSUM_HW is for a different calculation than what 5706 and tg3 are
providing here.  CHECKSUM_HW is for when the chip provides a raw 2's
complement 16-bit sum starting at a fixed offset from the beginning of
the packet.  The network stack then "undoes" or subtracts the header
2's complement checksum from the device provided sum to arrive at the
real checksum result.

5706 and tg3 are actually interpreting the headers and running the
checksum algorithm over the proper parts of the packet headers.
