From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: netxen: box stuck in netxen_napi_disable()
Date: Thu, 22 Jan 2015 09:37:01 +0100
Message-ID: <1421915821.5286.71.camel@marge.simpson.net>
References: <1421901805.5286.37.camel@marge.simpson.net>
	 <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421907358.5286.42.camel@marge.simpson.net>
	 <1421909520.3471.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:61871 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbbAVIhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 03:37:06 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so41876342wib.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 00:37:04 -0800 (PST)
In-Reply-To: <1421909520.3471.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-21 at 22:52 -0800, Eric Dumazet wrote: 
> On Thu, 2015-01-22 at 07:15 +0100, Mike Galbraith wrote:
> > On Wed, 2015-01-21 at 21:57 -0800, Eric Dumazet wrote:
> > 
> > > This driver doesn't follow the NAPI model correctly.
> > > 
> > > Please try following fix :
> > 
> > Thanks Eric, I'll plug it in in a bit and poke at it.  No news is good
> > news, as good as news gets for unknown repeatability bugs that is ;-)
> 
> To trigger the bug, all you had to do was to stress the transmit side.

Nope, it's easier than that...

> You could reduce MAX_STATUS_HANDLE from 64 to 4 to trigger it even
> faster.

Wow, that made it amazingly easy to verify.

With MAX_STATUS_HANDLE=4, without your patch applied box hangs as soon
as I bring the network up.  Add your patch on top, all is peachy.  Fresh
boot, or rmmod/modprobe and network restart, doesn't matter, box works
with your patch, is dead without it.

Here's an ornament for the fix if you think it'll look prettier :)

Reported-and-tested-by: Mike Galbraith <umgwanakikbuti@gmail.com>

-Mike
