From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: Intel and TOE in the news
Date: Sun, 20 Feb 2005 16:20:15 -0500
Message-ID: <30841.1108934415@marajade.sandelman.ottawa.on.ca>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org> <20050219114624.373af63f.davem@davemloft.net> <m1psywb8i4.fsf@muc.de>  <91f1bcca156f343c17918ce67ef23666@hp.com>
Cc: netdev@oss.sgi.com
To: rick jones <rick.jones2@hp.com>
In-Reply-To: Message from rick jones <rick.jones2@hp.com>
   of "Sun, 20 Feb 2005 11:45:02 PST." <91f1bcca156f343c17918ce67ef23666@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


>>>>> "rick" == rick jones <rick.jones2@hp.com> writes:
    >> - NIC receives packet.  - Tells target CPU to prefetch RX
    >> descriptor and headers.  - CPU later looks at them and doesn't
    >> have to wait a for a cache miss.
    >> 
    >> Drawback is that you would need to tell the NIC in advance on
    >> which CPU you want to process the packet, but with Linux IRQ
    >> affinity that's easy to figure out.

    rick> With all the interrupt avoidance that is going-on these days,
    rick> would prefetching in the driver be sufficient?  Presumably the
    rick> driver is going to be processing multiple packets at a time on
    rick> an interrupt/etc so having it issue prefetches in SW would
    rick> seem to help with all but the very first packet.

  I did prefetching of subsequent descriptor rings in the 200Mhz days,
when the descriptors lived in the NIC card. It's rather hard to write in
C :-)
  I did prefetching of packets on a PowerPC system (actually, it was
inside a TOE-like device, living in a Linux 1U). This was done with
altivec instructions, and was rather easy.
  On Intel, one can use MMX or floating point instructions to do the
prefetch. 
  
  The interrupt avoidance mechanism actually makes the prefetch easier,
since you are already in the bottom half, so it is easier to do. 
  The question is: how much to prefetch?

  BTW: in 1996 the IETF IPv6 WG briefly toyed with the idea of swapping
       the source and destination addresses in the IPv6 header. Having
       the dst first reduces a cache miss. They decided not to do this.

- -- 
] Michael Richardson          Xelerance Corporation, Ottawa, ON |  firewalls  [
] mcr @ xelerance.com           Now doing IPsec training, see   |net architect[
] http://www.sandelman.ca/mcr/    www.xelerance.com/training/   |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQhj/DYqHRg3pndX9AQHw8QP8CzXmHRgXWFOjU7TDpp4R73iiWmFtvrfq
NjFOQ9FbHkhk/xU47hwayOq8VA07Xh4baQa5YE824a2BbnFn88bz5A4kGeSia0/i
XLXEH+1d0QlWZ5ZJxPDwWyxszPorQpS8Mim+3GIcX24l2l9R7Y/x5hkVKHCZ/OuY
hukjy7DiObQ=
=h+QI
-----END PGP SIGNATURE-----
