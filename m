From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Top 10 kernel oopses/warnings for the week of December 21st 2007
Date: Fri, 21 Dec 2007 17:22:42 +0100
Message-ID: <20071221162242.GA29959@one.firstfloor.org>
References: <476BA8AF.4060201@linux.intel.com> <p73ejdgf8vj.fsf@bingen.suse.de> <476BCE15.6090902@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	"Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54827 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbXLUQVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 11:21:51 -0500
Content-Disposition: inline
In-Reply-To: <476BCE15.6090902@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> in this case this is really all the version information available ;(
> it seems to be a patched kernel without patched EXTRAVERSION.
> But in the future if I have more specific information (eg it's only 1 
> kernel version) I'll mention it in more detail.
> It gets unwieldy if there's 500 reports for an oops of course ;)

Hmm would there be an automatic way to check out the file of the 
kernel version and then check if the BUG_ON/WARN_ON is on that line?
Maybe it could be done using git.

> 
> >
> >Anyways there are a lot of third party modules who do strange 
> >things with c_p_a(), not always legal, so you might look up out for that 
> >pattern too. Perhaps report the out of tree modules loaded in the 
> >summary too?
> 
> I already always will mention if the oops is tainted or not (that I track 
> specifically);

I don't necessarily mean tainted, just out of tree modules in general.
There are some GPL modules who do strange things too. Not saying
that these oopses should be all ignored -- they might be legitimate
kernel bugs that they just trigger -- just it should be visible somehow
in the summary in case there is a pattern. 

Especially for c_p_a() i'm quite suspicious
because it depends a lot on what the caller did.

One way perhaps would be also to check if there is an out of tree
module inside the backtrace. I suppose you could keep a list 
of in tree modules and do this automatically. Of course there could
be false positives too with the standard inexact backtrace.

-Andi

