From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2] Ability to compile iproute2 as shared library
Date: Thu, 12 Jul 2012 23:43:16 +0100
Message-ID: <1342132996.2662.66.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342093501.19963.11.camel@gol>
	 <20120712090330.38dd5b37@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hamid jafarian <hamid.jafarian@pdnsoft.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62153 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1162102Ab2GLWnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 18:43:20 -0400
In-Reply-To: <20120712090330.38dd5b37@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 09:03 -0700, Stephen Hemminger wrote:
> On Thu, 12 Jul 2012 16:14:54 +0430
> hamid jafarian <hamid.jafarian@pdnsoft.com> wrote:
> 
> > Hi,
> > 
> > This is a try with minimum changes to compile iproute2 as shared
> > library.
> > Some functions would be used when we compile iproute2 as
> > shared library has been defined in "ip.c".
> > Also NICs caching strategy has been changed because, when we use
> > "libiproute2.so", system NIC list may change, so we should
> > re-cache all NICs at each call to NIC manipulation functions.
> > Also some call of "exit(*)" changed to "return *".
> > HOWTO Make: # export LIBIPROUTE2_SO=y; make
> > 
> > in attached files there is a simple wrapper to work with 
> > libiproute2.so ...
> > 
> 
> Thank you for the contribution. I can see how this could be useful
> in some limited embedded applications, but at this moment it doesn't
> seem to be generally worth adding to the upstream code.
> 
> The patch does contain some cleanup bits for where the existing
> code is not freeing stuff. This should be fixed, independent of
> whether library support is added, because it would remove the number
> of leaks reported when testing under valgrind. Could you resubmit
> that part please.

Compiling as a shared library would also mean commiting to managing the
ABI (i.e. bump the soversion every time you make an incompatible change,
and then try to avoid such changes too often).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
