From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: A case AGAINST checksum offload
Date: Mon, 15 Nov 2004 00:19:04 +0200
Message-ID: <20041114221904.GA29293@ee.oulu.fi>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu> <87mzxkxks5.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: John Heffner <jheffner@psc.edu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
Content-Disposition: inline
In-Reply-To: <87mzxkxks5.fsf@deneb.enyo.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Nov 14, 2004 at 09:01:14PM +0100, Florian Weimer wrote:
> * John Heffner:
> 
> > of the TCP/UDP checksum is to detect errors occurring outside the
> > protection of the link layer checksums -- errors when data is reassembled
> > or copied across busses inside hosts and routers.
> 
> The IP checksum is quite bad at catching those, though.  Broken memory
> banks or busses tend to introduce bit errors in distances which are
> multiples of 16 bits (something like 64 or 256).  Because of the way
> the IP checksum works, two such errors in the same packet cancel out
> and go undetected.
> I was once on the receiving end of such packets, and I can tell you
> it's not a fun thing to debug. 8-(
Btw., "When the CRC and TCP Checksum Disagree" 
http://citeseer.ist.psu.edu/stone00when.html is well worth reading.

Doesn't go into the offload vs. host IP checksum case too heavily, though,
I'm not sure if anyone really has data on that. The impression I have is 
that the risk isn't that big. If you're having flipped bits in
your (non-ECC :-) ) memory, you lose. If your PCI bus flips bits,
you probably lose when the data is read off disk. If your NIC has a
bad checksum engine, well... Then the IP checksums end up bad on the remote
end, packets get dropped, people tend to notice and that chip gets host-based
checksums soon enough. 

What definately would make sense is using user-space checksums (or just
transmit output from a PRNG + the seed and compare the streams)
in driver/hardware stress testing. And testing all those corner cases which
the driver/NIC might have gotten wrong.
