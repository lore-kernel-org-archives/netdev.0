From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Thu, 17 Jan 2013 17:27:32 -0800
Message-ID: <87mww71drv.fsf@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87a9s772zw.fsf@xmission.com>
	<1358470823.15692.156.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47349 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab3ARB1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 20:27:46 -0500
In-Reply-To: <1358470823.15692.156.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Fri, 18 Jan 2013 01:00:23 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Thu, 2013-01-17 at 16:23 -0800, Eric W. Biederman wrote:
>> Ben Hutchings <bhutchings@solarflare.com> writes:
>> 
>> > On Mon, 2012-11-26 at 17:16 -0600, Eric W. Biederman wrote:
> [...]
>> >> --- a/ip/ipnetns.c
>> >> +++ b/ip/ipnetns.c
> [...]
>> >> +static int is_pid(const char *str)
>> >> +{
>> >> +	int ch;
>> >> +	for (; (ch = *str); str++) {
>> >> +		if (!isdigit(ch))
>> >
>> > ch must be cast to unsigned char before passing to isdigit().
>> 
>> isdigit is defined to take an int.  A legacy of the implicit casts in
>> the K&R C days.  Casting to unsigned char would be pointless and silly.
> [...]
>
> It's not pointless.  This is explained in the very first line of the
> description in the manual page...

If it's not pointless it is an implementation bug.  The conversion to of
char to int happens implicitly whenever you pass a char.  It is
absolutely broken to have a function that takes a char converted to int
and reject the automatic conversion of char to int.

I suspect much more strongly that it is a case of poor documentation.

If isdigit can't deal with what I have passed it I will be much more
interested in writing a patch for isdigit.

That said I just dobule checked with the code below.  Negative character
values work correctly and don't cause any runtime errors.

It looks like it is time to update the manpage to remove that
confusing/wrong sentence.

Eric

#include <ctype.h>
#include <limits.h>
#include <stdio.h>

int main(int argc, char **argv)
{
	char c;
	for (c = CHAR_MIN; c < CHAR_MAX; c++) {
		printf("c: %d isdigit: %d\n",
		       c, isdigit(c));
	}
	return 0;
}
