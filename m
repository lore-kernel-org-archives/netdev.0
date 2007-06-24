From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] ESFQ: request for user input
Date: Sun, 24 Jun 2007 23:12:40 +0200
Message-ID: <467EDE48.307@trash.net>
References: <467ECB0C.6020105@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc <lartc@mailman.ds9a.nl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51037 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbXFXVMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 17:12:52 -0400
In-Reply-To: <467ECB0C.6020105@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Hello,
> 
> I haven't been keeping up with sending ESFQ [ANNOUNCE] messages to this
> list, but I've still been working on the patch. If you're curious about
> recent changes, take a look at the home page, ChangeLog, and README:
> 
> http://fatooh.org/esfq-2.6/
> http://fatooh.org/esfq-2.6/current/ChangeLog
> http://fatooh.org/esfq-2.6/current/README
> 
> Meanwhile, I'm interested in finally getting ESFQ included in the Linux
> kernel. Before I start sending patches and requesting maintainer review,
> however, there's one question I want to ask current or potential users
> of SFQ and ESFQ:
> 
> Should ESFQ be merged into SFQ or remain as a separate qdisc?


I've CCed netdev. I think merging parts of ESFQ (dynamic depth and
flow number) would make a lot of sense, but I'm intending to submit
an alternative to the ESFQ hashing scheme for 2.6.23:

http://www.mail-archive.com/netdev@vger.kernel.org/msg39156.html

I have enough trust in ESFQ's stability that I don't think we need
a new qdisc for this and could merge it in SFQ (and the "uses only
1 page" justification isn't true anymore anyway), but I also
wouldn't mind adding a new qdisc.

> Note that I can't promise either is an option, since I haven't queried
> any maintainers yet; I'd rather have a clear idea of what is more
> desirable to the users before I propose anything. Of course, if any
> maintainers read this, I would value their input at this point as well.
> 
> Here are some advantages and disadvantages of merging ESFQ with SFQ.
> Please correct me or let me know of any others you think of.
> 
> ---Advantages---
> * There's nothing radically different about ESFQ. A separate sch_esfq.c
>   would duplicate lots of the code in sch_sfq.c.
> * Current users of SFQ would benefit from the better hashing of using
>   jhash. Other than that, the default parameters of ESFQ are the same
>   as SFQ's hardcoded values, so ESFQ would be a drop-in replacement.
> * Having two similar-looking similarly-functioning qdiscs could be
>   confusing for new users.
> 
> ---Disadvantages---
> * SFQ has been stable for years; it may be undesirable to make changes
>   that could potentially introduce bugs.
> * ESFQ is marginally slower than SFQ (although I haven't been able to
>   measure a practical difference; if someone has benchmark tips I'll try
>   them).
