From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2 1/2] utils: add s32 parser
Date: Fri, 25 Nov 2011 17:34:21 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE6@saturn3.aculab.com>
References: <20111125092451.19e0e9d4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Hagen Paul Pfeifer" <hagen@jauu.net>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46465 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752300Ab1KYRgR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 12:36:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15589-04 for <netdev@vger.kernel.org>;
 Fri, 25 Nov 2011 17:36:14 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20111125092451.19e0e9d4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
> "David Laight" <David.Laight@ACULAB.COM> wrote:
> 
> > > +	res = strtoul(arg, &ptr, base);
> > > +	if (!ptr || ptr == arg || *ptr || res > INT32_MAX || res <  
> > INT32_MIN)
> > 
> > No need to check !ptr.
> 
> Also don't you want signed value?  Reading strtol() man page,
> the correct way is:
> 	errno = 0;
> 	res = strtol(arg, &ptr, base);
> 	if (ptr == arg || errno)
> 		return -1;
> 
> "RETURN VALUE
>        The strtol() function returns the result of the conversion,
unless  the
>        value  would  underflow  or overflow.  If an underflow occurs,
strtol()
>        returns LONG_MIN.  If an overflow occurs,  strtol() returns
LONG_MAX.
>        In  both  cases,  errno is set to ERANGE.  Precisely the same
holds for
>        strtoll()  (with  LLONG_MIN  and  LLONG_MAX  instead  of
LONG_MIN  and
>        LONG_MAX).

If you are that worried about numeric overflow (IIRC) you have
have to check the result for LONG_MIN/MAX (etc) before looking
at errno.

strtoul() is defined to support -ve values, and I think the
C rules for conversion between signed and unsigned ints
DTRT even for non 2's compliment systems.

Some of these bound checks are a waste of time.
The SUS doesn't require standard utilities to perform them.

	David
