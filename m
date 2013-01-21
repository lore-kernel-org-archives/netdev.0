From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Mon, 21 Jan 2013 09:52:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B711A@saturn3.aculab.com>
References: <87a9u4q7k9.fsf@xmission.com><1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com><87a9s772zw.fsf@xmission.com><1358470823.15692.156.camel@deadeye.wl.decadent.org.uk><87mww71drv.fsf@xmission.com><1358517218.21229.6.camel@deadeye.wl.decadent.org.uk> <87ehhiqqb3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35074 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751404Ab3AUJyf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 04:54:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03639-01 for <netdev@vger.kernel.org>;
 Mon, 21 Jan 2013 09:54:30 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <87ehhiqqb3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> >> >> +		if (!isdigit(ch))
> >> >> >
> >> >> > ch must be cast to unsigned char before passing to isdigit().
> >> >>
> >> >> isdigit is defined to take an int.  A legacy of the implicit casts in
> >> >> the K&R C days.  Casting to unsigned char would be pointless and silly.
> >> > [...]
> >> >
> >> > It's not pointless.  This is explained in the very first line of the
> >> > description in the manual page...
> >>
> >> If it's not pointless it is an implementation bug.
> >
> > You can either get in your time machine and go back to 1978 and fix it,
> > or add the cast like every C programmer who knows what the C standards
> > say about these functions.
> 
> So I took a moment to look. The C standard is indeed does not say
> anything about this and supporting signed char becomes a quality of
> implementation issue.  glibc supports being passed signed character
> values.

You must have looked in the wrong place.
The standards documentation on all the ctype functions is very clear
about the valid input domain.

> > Testing on one implementation doesn't prove anything.  'char' can be
> > signed or unsigned depending on the architecture, and some C libraries
> > work around buggy applications that .  That's no reason to write another
> > buggy application.
> 
> This code by it's very nature is not portable.  The code is not suid
> so insane level of paranoia don't need to be maintained.

What!!!! You still don't want core dumps due to invalid input.
Especially if the input might be from a file.
I did the full trawl of NetBSD's 'src' tree because of issues with
one of the shells faulting.

> The definition
> in the C standard is a least common denominator requirement.  Posix
> copies that least common denominator requirement.  Glibc does not
> implment the least common denominator.

Unless you writes 'standards compliant' programs, you will eventually
fall foul of these sort of problems.

Are you sure that glibc will always be used? What about newlib?

There may be strict requirements on isdigit() (I think you are
allowed to subtract '0' to get a number). The same is not true
of isprint(), isprint(EOF) is FALSE, isprint(255) may be TRUE
(ij ligature).

	David
