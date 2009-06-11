From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 19:45:07 +0200
Message-ID: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
	 <1244732090.2785.12.camel@achroite>
	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	 <1244739166.2785.52.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Pitre <nico@cam.org>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:37646 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbZFKRpH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 13:45:07 -0400
Received: by ewy6 with SMTP id 6so2228067ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 10:45:08 -0700 (PDT)
In-Reply-To: <1244739166.2785.52.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 6:52 PM, Ben Hutchings<bhutchings@solarflare.co=
m> wrote:
> It's an example of providing a generic solution, which is definitely
> more than a quick hack, but I don't see it as a "clean solution" for =
the
> problem that certain link modes don't work on a particular board. =A0=
A
> clean solution would disable those modes altogether in the driver.
>
I don't see why this is cleaner.
It may be slightly safer as someone can't later run ethtool and mess th=
ings up.

And how do you propose disabling it in the driver?
Either we're back to quick driver specific hacks  (which is what I
initially did before writing this patch) or we need a new in kernel
interface to be implemented by all the network drivers to filter their
capabilities.

The problems with the quick hack approach are:
1) Different for each driver
2) Need to understand how each driver works to do it
3) Need to maintain the driver patch against evolving kernel

And all this work will be done again and again by everyone that has
this problem.

OTOH adding a new interface to all the drivers is a "one off" effort
but _much_ more intrusive than my patch.
As we are arguing over if its worth adding a patch which requires zero
driver modifications and has zero impact for those that chose not to
enable it I don't see how adding a new interface to all the network
drivers just to meet the needs  of a few embedded people would ever be
accepted...

Martin
