From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Fri, 18 Jan 2013 10:49:52 -0800
Message-ID: <87ehhiqqb3.fsf@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87a9s772zw.fsf@xmission.com>
	<1358470823.15692.156.camel@deadeye.wl.decadent.org.uk>
	<87mww71drv.fsf@xmission.com>
	<1358517218.21229.6.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49278 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARSuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 13:50:14 -0500
In-Reply-To: <1358517218.21229.6.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Fri, 18 Jan 2013 13:53:38 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Thu, 2013-01-17 at 17:27 -0800, Eric W. Biederman wrote:
>> Ben Hutchings <bhutchings@solarflare.com> writes:
>> 
>> > On Thu, 2013-01-17 at 16:23 -0800, Eric W. Biederman wrote:
>> >> Ben Hutchings <bhutchings@solarflare.com> writes:
>> >> 
>> >> > On Mon, 2012-11-26 at 17:16 -0600, Eric W. Biederman wrote:
>> > [...]
>> >> >> --- a/ip/ipnetns.c
>> >> >> +++ b/ip/ipnetns.c
>> > [...]
>> >> >> +static int is_pid(const char *str)
>> >> >> +{
>> >> >> +	int ch;
>> >> >> +	for (; (ch = *str); str++) {
>> >> >> +		if (!isdigit(ch))
>> >> >
>> >> > ch must be cast to unsigned char before passing to isdigit().
>> >> 
>> >> isdigit is defined to take an int.  A legacy of the implicit casts in
>> >> the K&R C days.  Casting to unsigned char would be pointless and silly.
>> > [...]
>> >
>> > It's not pointless.  This is explained in the very first line of the
>> > description in the manual page...
>> 
>> If it's not pointless it is an implementation bug.
>
> You can either get in your time machine and go back to 1978 and fix it,
> or add the cast like every C programmer who knows what the C standards
> say about these functions.

So I took a moment to look. The C standard is indeed does not say
anything about this and supporting signed char becomes a quality of
implementation issue.  glibc supports being passed signed character
values.

> Testing on one implementation doesn't prove anything.  'char' can be
> signed or unsigned depending on the architecture, and some C libraries
> work around buggy applications that .  That's no reason to write another
> buggy application.

This code by it's very nature is not portable.  The code is not suid
so insane level of paranoia don't need to be maintained.  The definition
in the C standard is a least common denominator requirement.  Posix
copies that least common denominator requirement.  Glibc does not
implment the least common denominator.

There is no advantage for an implemenation to implement only the least
common denominator of functionality in isdigit.  There is a huge
advantage for an implementation of the cypte functions on platforms with
signed char to have an array with 384 entries.  It is nearly humanly
impossible to remember you need to type isdigit((unsigned)string[n]),
not to mention how easy it is for casts to go wrong.

So no I do not consider programs that are not strictly conformant with
the C standard broken.  I consider implementations of isdigit that are
strictly conformat with the C standard to be canidadates for patches.
At this point I will happily add support to any ctype implemenation I
meet that has such a poor quality of implementation that you have to be
a language lawyer in top form to use isdigit properly.

Eric
