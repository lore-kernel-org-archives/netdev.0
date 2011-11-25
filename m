From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 1/2] utils: add s32 parser
Date: Fri, 25 Nov 2011 09:24:51 -0800
Message-ID: <20111125092451.19e0e9d4@nehalam.linuxnetplumber.net>
References: <1322156415-23331-1-git-send-email-hagen@jauu.net>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AEE2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Hagen Paul Pfeifer" <hagen@jauu.net>, <netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50553 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883Ab1KYRYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 12:24:54 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Nov 2011 09:46:09 -0000
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > +	res = strtoul(arg, &ptr, base);
> > +	if (!ptr || ptr == arg || *ptr || res > INT32_MAX || res <  
> INT32_MIN)
> 
> No need to check !ptr.

Also don't you want signed value?  Reading strtol() man page,
the correct way is:
	errno = 0;
	res = strtol(arg, &ptr, base);
	if (ptr == arg || errno)
		return -1;

"RETURN VALUE
       The strtol() function returns the result of the conversion, unless  the
       value  would  underflow  or overflow.  If an underflow occurs, strtol()
       returns LONG_MIN.  If an overflow occurs,  strtol()  returns  LONG_MAX.
       In  both  cases,  errno is set to ERANGE.  Precisely the same holds for
       strtoll()  (with  LLONG_MIN  and  LLONG_MAX  instead  of  LONG_MIN  and
       LONG_MAX).
