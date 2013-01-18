From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns
 identify"
Date: Fri, 18 Jan 2013 13:53:38 +0000
Message-ID: <1358517218.21229.6.camel@deadeye.wl.decadent.org.uk>
References: <87a9u4q7k9.fsf@xmission.com>
	 <1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	 <87a9s772zw.fsf@xmission.com>
	 <1358470823.15692.156.camel@deadeye.wl.decadent.org.uk>
	 <87mww71drv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47016 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755628Ab3ARNxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 08:53:48 -0500
In-Reply-To: <87mww71drv.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 17:27 -0800, Eric W. Biederman wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> 
> > On Thu, 2013-01-17 at 16:23 -0800, Eric W. Biederman wrote:
> >> Ben Hutchings <bhutchings@solarflare.com> writes:
> >> 
> >> > On Mon, 2012-11-26 at 17:16 -0600, Eric W. Biederman wrote:
> > [...]
> >> >> --- a/ip/ipnetns.c
> >> >> +++ b/ip/ipnetns.c
> > [...]
> >> >> +static int is_pid(const char *str)
> >> >> +{
> >> >> +	int ch;
> >> >> +	for (; (ch = *str); str++) {
> >> >> +		if (!isdigit(ch))
> >> >
> >> > ch must be cast to unsigned char before passing to isdigit().
> >> 
> >> isdigit is defined to take an int.  A legacy of the implicit casts in
> >> the K&R C days.  Casting to unsigned char would be pointless and silly.
> > [...]
> >
> > It's not pointless.  This is explained in the very first line of the
> > description in the manual page...
> 
> If it's not pointless it is an implementation bug.

You can either get in your time machine and go back to 1978 and fix it,
or add the cast like every C programmer who knows what the C standards
say about these functions.

> The conversion to of
> char to int happens implicitly whenever you pass a char.  It is
> absolutely broken to have a function that takes a char converted to int
> and reject the automatic conversion of char to int.

It doesn't take a char... weird but that is how it is defined.

> I suspect much more strongly that it is a case of poor documentation.
>
> If isdigit can't deal with what I have passed it I will be much more
> interested in writing a patch for isdigit.
> 
> That said I just dobule checked with the code below.  Negative character
> values work correctly and don't cause any runtime errors.
[...]

Testing on one implementation doesn't prove anything.  'char' can be
signed or unsigned depending on the architecture, and some C libraries
work around buggy applications that .  That's no reason to write another
buggy application.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
