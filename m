From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Tue, 7 Dec 2004 17:10:26 -0800
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C0293B459@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Ray Lehtiniemi" <rayl@mail.com>, "Scott Feldman" <sfeldma@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > What kind of numbers are you getting?
> 
> i'm seeing about 100Kpps, with all settings at their defaults on the
> 2.4.20
> kernel.
> 
> basically, i have a couple of desktop PCs generating 480 streams
> of UDP data at 50 packets per second.  Packet size on the wire,
including
> 96 bits of IFG, is 128 bytes.  these packets are forwarded through a
user
> process on the NexGen box to an echoer process which is also running
on
> the
> traffic generator boxes. the echoer sends them back to the NexGen user
> process,
> which forwards them back to the generator process.  timestamps are
logged
> for each packet at send, loop and recv points.
> 

I'm not much of an expert, but one easy thing to try is to up your
receive stack resources, as they were particularly low on 2.4 series
kernels, leading to udp getting overrun pretty easily with gig nics.  I
think if you make the value go too high it just ignores it, so if you
see no change, try 256kB instead.

cat /proc/sys/net/core/rmem_default
cat /proc/sys/net/core/rmem_max 

echo -n 512000 > /proc/sys/net/core/rmem_default
echo -n 512000 > /proc/sys/net/core/rmem_max

Jesse
