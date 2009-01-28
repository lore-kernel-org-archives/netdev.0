From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Wed, 28 Jan 2009 12:29:24 -0800 (PST)
Message-ID: <20090128.122924.106238702.davem@davemloft.net>
References: <20090122191239.GA16347@uranus.ravnborg.org>
	<20090126.210835.181389836.davem@davemloft.net>
	<alpine.LSU.2.00.0901271143490.3147@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, andrew@walrond.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39415
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754455AbZA1U31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:29:27 -0500
In-Reply-To: <alpine.LSU.2.00.0901271143490.3147@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Tue, 27 Jan 2009 11:44:51 +0100 (CET)

> 
> On Tuesday 2009-01-27 06:08, David Miller wrote:
> >The fly in the ointment is linux/if_tunnel.h
> >
> >We export a structure there for a userland interface which
> >uses "struct iphdr".
> >
> >Because of that, we are faced with the difficult choice between
> >defining the structure (as we do) in linux/ip.h or using some ugly
> >__KERNEL__ ifdefs in linux/if_tunnel.h to conditionally include
> >netinet/ip.h instead. :-/
> >
> >Really, I have no idea what to do about this as the problem has
> >existed for so long.
> 
> I think in the long term, exported structs should probably
> have a "kernel_" prefix, much like userspace libraries use
> such prefixes to (try to) guard against simple name clashes.

This is a reasonable rule for future interfaces, but won't
help us here on this one.

For one thing, users can be making use of the inner types
to build the blobs they send via these interfaces.  So it's
not like we can rename "struct iphdr" to "struct kernel_iphdr"
to fix this particular case.

Really, we page a huge price these days because the relationship
between glibc's and the kernel's userland header exports in the
past has been anti-social at best.
