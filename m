From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 09:31:50 +0000
Message-ID: <20080307093150.GA4203@ff.dom.local>
References: <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local> <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local> <20080306233151.M43262@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:30206 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762059AbYCGJah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 04:30:37 -0500
Received: by nf-out-0910.google.com with SMTP id g13so207347nfb.21
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 01:30:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080306233151.M43262@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 01:43:33AM +0200, Denys Fedoryshchenko wrote:
> About reproducing, I think .config matter
> Mine is at http://www.nuclearcat.com/files/config.txt

I see: CONFIG_4KSTACKS=y  but CONFIG_DEBUG_STACKOVERFLOW is not set.
This doesn't look safe to me... And can trigger really strange things.

Probably dmesg could be interesting too. And since it all takes place
and can change in time, I wonder if it isn't better to open a report
in bugzilla for this. Of course, you should remember to mask any
confidential information.

I'm also not sure this: 
http://www.nuclearcat.com/files/bug_feb.txt
is a full script (no more ifbs?) or an example. Doesn't "magic sysrq"
work during such lockups?

Denys, there were some reports on similar problems with ifb on SMP,
but this was hard to trigger and debugging stopped for some reason.
It seems there were some timer OOPSes, but this could be because
wrong locking too. This could be even because some other apps can't
handle their lost net traffic. Without some good log traces this could
be impossible to tell. And such debugging shouldn't be done at
production of course: it's really hard to foresee any locking changes.
So, until you are willing to respond to our proposals and try the
patches I can see no problem with assisting this problem.

BTW, probably it's easier to stick to one kernel version, so maybe
2.6.24.3 isn't a bad choice if 2.6.25-rc4 didn't help at all.
 
Regards,
Jarek P.
