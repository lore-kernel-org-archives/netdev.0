From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 08:11:18 +0300
Message-ID: <20150428051118.GA25672@angus-think.lan>
References: <553EE0D9.3050601@ionic.de>
 <20150428040516.GA14129@angus-think.lan>
 <553F0D8E.9060602@ionic.de>
 <20150428044708.GA22671@angus-think.lan>
 <553F15AC.3080606@ionic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org,
	Bernard Cafarelli <voyageur@gentoo.org>
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35378 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbD1FLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 01:11:39 -0400
Received: by lbbuc2 with SMTP id uc2so98289751lbb.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 22:11:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <553F15AC.3080606@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 07:07:56AM +0200, Mihai Moldovan wrote:
> On 28.04.2015 06:47 AM, Vadim Kochan wrote:
> > On Tue, Apr 28, 2015 at 06:33:18AM +0200, Mihai Moldovan wrote:
> >> On 28.04.2015 06:05 AM, Vadim Kochan wrote:> So by default ss prints
> >> socket with CONNECTED state and even UDP can be
> >>> in the CONNECTED state on the Linux,
> >> 
> >> UDP can be in a CONNECTED state... ooookay. That's probably a conntrack 
> >> thing.
> >> 
> >> 
> >>> so you can specify 'ss -ua' (may be some explanation should be added to 
> >>> the ss man page) which should print UDP sockets in the any state, AFAIK 
> >>> it was the default behaviour before my changes.
> >> 
> >> Could this please be reverted? It's breaking other stuff that uses ss.
> >> 
> >> Also: ss -lxua returns an empty list, too. Previously, the families seem
> >> to have been OR'd, while they are now ANDed?
> >> 
> >> 
> >> 
> >> Mihai
> >> 
> > 
> > I will try to fix this ...
> 
> Thanks!
> 
> To be a bit more verbose about the rationale:
> 
> Changing the default behavior is generally a bad idea, unless strictly necessary
> (e.g., if the previous default behavior was buggy anyway), because it may break

Yes the previous behaviour was buggy ... And that was the reason.

> other software. Please try introducing behavioral changes via new options.
> 
> That way, dependencies will still work fine and anyone who wants to use the new
> behavior can explicitly do so via a switch.
> 
> I could work around this by checking ss' version, but that turns out to be a
> pain, too, because ss -V reports something like this:
> 
> "ss utility, iproute2-ss150413"
> 
> Not exactly a "friendly" version like "3.19.0" or "4.0.0" to check against...
> 
> 
> 
> Mihai
> 
> 
