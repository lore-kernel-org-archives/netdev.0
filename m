From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 19:31:59 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031213159.GO3705@conectiva.com.br>
References: <200310312006.h9VK62Hh005910@hera.kernel.org> <1067635446.11564.92.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
Content-Disposition: inline
In-Reply-To: <1067635446.11564.92.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Oct 31, 2003 at 01:24:06PM -0800, Joe Perches escreveu:
> On Thu, 2003-10-30 at 19:43, Linux Kernel Mailing List wrote:
> > ChangeSet 1.1399, 2003/10/30 19:43:04-08:00, davem@nuts.ninka.net
> > 	[IPX]: Fix checksum computation.
> > diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> > --- a/net/appletalk/ddp.c	Fri Oct 31 12:06:06 2003
> > +++ b/net/appletalk/ddp.c	Fri Oct 31 12:06:06 2003
> > @@ -937,9 +937,13 @@
> >  {
> >  	/* This ought to be unwrapped neatly. I'll trust gcc for now */
> >  	while (len--) {
> > -		sum += *data++;
> > +		sum += *data;
> >  		sum <<= 1;
> > -		sum = ((sum >> 16) + sum) & 0xFFFF;
> > +		if (sum & 0x10000) {
> > +			sum++;
> > +			sum &= 0xffff;
> > +		}
> > +		data++;
> >  	}
> >  	return sum;
> >  }
> 
> This change didn't appear on this list for comment,
> it just appeared in the source.
> 
> Why is this a "fix"?  Performance?
> It seems more like someone's idea of code neatening.
> 
> If this is done, why not if (unlikely())

No, the reverse is true, with the patch it is the same as in 2.4, when Stephen
did the conversion to handle paged skbs it did what you called "neatening"
(i.e.  without the patch above), now, if you care, go try to use this with
recent gcc, and get back with your results.

Mine were: reversing this patch makes the checksum calculations sometimes
wrong, preventing Appletalk from working.

Mind boggling? Yes, did it fixed a problem? Yes.

- Arnaldo
