From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11655] New: /proc/sys/net/ipv6/conf/all/*
 controls don't work
Date: Mon, 13 Oct 2008 11:37:26 -0700 (PDT)
Message-ID: <20081013.113726.193048941.davem@davemloft.net>
References: <20081002231826.869a1a9e.akpm@linux-foundation.org>
	<20081013.003239.89070363.davem@davemloft.net>
	<20081013101334.6b8b4567@zonk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: adwol@zonk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49941
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755181AbYJMShu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 14:37:50 -0400
In-Reply-To: <20081013101334.6b8b4567@zonk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Osuchowski <adwol@zonk.pl>
Date: Mon, 13 Oct 2008 12:13:34 +0200

> David Miller wrote:
> > Not a bug.
> > 
> > These "global" setting have to be set to the desired value before the
> > device is created.  And it is at creation time that these global
> > values are "inherited" by the device.
> > 
> > Afterwards changes to the global value will not propagate to those
> > devices again, because that might override a changed setting made
> > by the user.
> > 
> > It is only newly created devices which get these values.
> 
> I understand you are talking about /proc/sys/net/ipv6/conf/default/*
> controls. If so, it's ok, but I talked about /proc/sys/net/ipv6/conf/all/*
> controls. Documentation/networking/ip-sysctl.txt says:
> 
>     conf/default/*:
> 	    Change the interface-specific default settings.
> 
> 
>     conf/all/*:
> 	    Change all the interface-specific settings.
> 
> so what is the difference between default and all in the context of your
> statement? In my opinion, it could be understood that default settings
> are inherited and those from "all" directory change values for all
> current devices.

Unfortunately not all "all" knobs are treated universally, only some
of them all.

If you grep for "devconf_all" under net/ipv6 you'll see which ones
get used and in what manner.

Of course, we'll need to tweak either the docs or the implementation
to match :-)
