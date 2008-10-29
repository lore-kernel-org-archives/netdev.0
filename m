From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: oh crap... (re: %p6)
Date: Wed, 29 Oct 2008 11:21:19 -0700
Message-ID: <1225304479.5688.28.camel@brick>
References: <20081029.015402.234525839.davem@davemloft.net>
	 <1225292124.20276.12.camel@brick>  <1225294760.5269.301.camel@localhost>
	 <1225301082.5688.24.camel@brick>  <1225304214.5269.339.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:22423 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbYJ2S2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:28:21 -0400
Received: by an-out-0708.google.com with SMTP id d40so13794and.103
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 11:28:19 -0700 (PDT)
In-Reply-To: <1225304214.5269.339.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 11:16 -0700, Joe Perches wrote:
> On Wed, 2008-10-29 at 10:24 -0700, Harvey Harrison wrote:
> > Putting a modifier after the format specifier seems a little strange to me.
> 
> Harvey, please remember the whole %p<foo> concept is based on
> modifier after format specifier.
> 
> I think %p6 followed by combinations of things:
> 
> "::" compressed v6, largest block of consecutive 0's replaced with ::
> "-:" no separating colons, use space instead
> "-0" no leading 0's
> ".4" last word as ipv4 dotted decimal
> "x1" u8 form
> "x2" be16
> "x4" be32
> "x8" be64
> 

Yes, but if you put anything but alphanumerics after the %p, make sure
you handle that in vsnprintf(), so it will be a bit more involved than
my simplistic ones were.

> So that you could have:
> 
> %p6::		1234:000a::c0a8:0101
> %p6::-0		1234:a::c0a8:0101
> %p6::-0.4	1234:a::192.168.1.1
> %p6-0-:x1	0 1 2 3 4 5 6 7 8 9 a b c d e f
> %p6x1		00:01:02:03:04:05:06:07:09:0a:0b:0c:0d:0e:0f
> 
> etc.  If acceptable, I'll submit a patch.
> 

I'll let Dave comment on whether this flexibility is desired.  Mine was
more an attempt to consolidate a very common (and simplisitic) usage.


Cheers,

Harvey


