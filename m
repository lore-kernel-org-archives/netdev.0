From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: A case AGAINST checksum offload
Date: Sun, 14 Nov 2004 21:01:14 +0100
Message-ID: <87mzxkxks5.fsf@deneb.enyo.de>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu> (John Heffner's
	message of "Fri, 12 Nov 2004 18:46:11 -0500 (EST)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* John Heffner:

> Currently with many common Ethernet devices in Linux, hardware TCP
> checksumming is enabled by default.  This seems fairly dangerous to me.
> Most link layer checksums are much stronger than the TCP/UDP checksum;
> most bit errors are caught by these.  However, one of the primary purposes
> of the TCP/UDP checksum is to detect errors occurring outside the
> protection of the link layer checksums -- errors when data is reassembled
> or copied across busses inside hosts and routers.

The IP checksum is quite bad at catching those, though.  Broken memory
banks or busses tend to introduce bit errors in distances which are
multiples of 16 bits (something like 64 or 256).  Because of the way
the IP checksum works, two such errors in the same packet cancel out
and go undetected.

I was once on the receiving end of such packets, and I can tell you
it's not a fun thing to debug. 8-(
