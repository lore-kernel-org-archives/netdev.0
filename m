From: David Miller <davem@davemloft.net>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 17:06:23 -0800 (PST)
Message-ID: <20090226.170623.247704052.davem@davemloft.net>
References: <49A69784.6070204@free.fr>
	<20090226.052411.77955912.davem@davemloft.net>
	<20090226180920.GO28512@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.lezcano@free.fr, netdev@vger.kernel.org
To: matti.aarnio@zmailer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751236AbZB0BGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 20:06:42 -0500
In-Reply-To: <20090226180920.GO28512@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Aarnio <matti.aarnio@zmailer.org>
Date: Thu, 26 Feb 2009 20:09:20 +0200

> On Thu, Feb 26, 2009 at 05:24:11AM -0800, David Miller wrote:
> > It's just such an enormous set of problems to solve to make it work,
> > and there are so many more urgent issues to work on.
> 
> Like refactoring the system to have IPv4 specific codes,
> IPv6 specific codes, and common codes...   But DaveM has
> probably other items in mind.

The biggest problem is the reference counting of objects.

And if you make ipv6 sockets grab references to the ipv6 module,
the ipv6 module itself creates a few for ICMP6 processing, so
you somehow have to get rid of those in order for the module
unload to be invokable at all.

There are hundreds of cases like that you have to find solutions for
before you can cleanly unload ipv6.
