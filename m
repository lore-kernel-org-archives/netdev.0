From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 13:37:37 +0200
Message-ID: <20100805113721.GI9031@bicker>
References: <20100805093806.GF9031@bicker> <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com> <20100805101938.GH9031@bicker> <AANLkTi=8ThVqTHpQmDfoon02C-VZ0JwBRtSrU7dzvvNt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47460 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758869Ab0HELhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 07:37:54 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=8ThVqTHpQmDfoon02C-VZ0JwBRtSrU7dzvvNt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 05, 2010 at 07:02:06PM +0800, Changli Gao wrote:
> 
> the second parameter of strlcpy() must a NUL terminated C string. I
> think you means strncpy().
> 

Both strncpy() and strlcpy() take a limitter.  The difference is that
strlcpy() always takes on a terminator and strncpy() only adds a
terminator if there is space.

strlcpy() is a BSD function that never caught on in Linux.  The glibc
maintainers think that if you accidentally chop off the last part of a
word that makes you an idiot.  They think you should known the length of
your data at all times and use memcpy() or a proper string library.

I prefer strlcpy() to strncpy().  Some people do stuff like:
	strncpy(bar, foo, n);
	bar[n] = '\0';
You have to read through the code to find if n is "sizeof(bar)" or
"sizeof(bar) - 1".  Which is a pain in the arse.  strlcpy() is explicit
and it's just one line of code instead of two.

The other tricky thing you should remember about strncpy() is that the
posix version writes NUL chars from the end of the string to the
limitter but the kernel version only copies one NUL character.

regards,
dan carpenter

> FYI:
> http://lxr.linux.no/#linux+v2.6.35/lib/string.c#L146
> http://lxr.linux.no/#linux+v2.6.35/lib/string.c#L119
> 

