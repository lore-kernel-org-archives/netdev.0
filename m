From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Fri, 12 Jun 2009 14:19:11 +0200
Message-ID: <ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>
References: <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	 <1244739166.2785.52.camel@achroite>
	 <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
	 <20090611.170948.66762524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:55559 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbZFLMTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 08:19:10 -0400
Received: by bwz9 with SMTP id 9so2033828bwz.37
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 05:19:12 -0700 (PDT)
In-Reply-To: <20090611.170948.66762524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 2:09 AM, David Miller<davem@davemloft.net> wrote:

> You can instantiate a platform_device that the driver matches
> and uses to acquire board-specific-juju such as link modes
> which are non-functional.
>
Just to make sure I'm understanding you here - that would still
require modifying each and every network driver to use and interpret
the said platform_device right?
This proposal doesn't require _any_ changes to the network device drivers.
It also doesn't have _any_ impact on the kernel for those that don't enable it.

The smc9x driver contains this comment :
/*
 * The internal workings of the driver.  If you are changing anything
 * here with the SMC stuff, you should have the datasheet and know
 * what you are doing.
 */
Before writing this patch I had to disregard this to do the hacked version.
I wasn't touching the driver to improve it or fix it - in which case
it would be quite reasonable to expect me to have read the datasheet
but just to turn off a bit of functionality to work around broken
hardware.

Why should people have to dabble in driver internals just to say
"please use this mode"?
The proposed patch allows you to do this in a portable way so that
when you work on another board with a different network chip you don't
need to do it all again.

I thought I'd done everything right;I posted a question on the mailing
list, _before_ writing any code, discussion ensued and we seemed to
reach a consensus as when Nicolas proposed this solution you said:

>And you could even write it and maintain it somewhere if you
>like for other embedded people to use. :-)
>Once full featured, I'd be happy to include it.

So I went off and implemented it.
I'm not claiming  it's perfect but we're not even discussing the
implementation and how to improve it but have gone back to discussing
if we should even be doing it. This is _very_ fusttrating

Martin
