From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Fri, 2 Dec 2011 10:09:35 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A0491C@mail733.InfraSupportEtc.com>
References: <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com> <20111201165040.GL589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com> <4ED8F15D.8020909@ziu.info> <20111202160442.GQ589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>,
	"Michal Soltys" <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:59167 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982Ab1LBQJg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 11:09:36 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

..and as much as I went into the proxy thing kicking and screaming, it
does seem clean and simple now that I finally did it.

The routing still has me confused - my public host is on the router's
eth1, its gateway is on eth0, but it all still works.  I should probably
reboot that router at some point soon to make sure there aren't any
hidden legacies from my old bridge config left over.  

- Greg


-----Original Message-----
From: David Lamparter [mailto:equinox@diac24.net] 
Sent: Friday, December 02, 2011 10:05 AM
To: Michal Soltys
Cc: Greg Scott; David Lamparter; netdev@vger.kernel.org
Subject: Re: ebtables on a stick

On Fri, Dec 02, 2011 at 04:40:13PM +0100, Michal Soltys wrote:
> You should be able to avoid whole proxy thing altogether (on your 
> router), by doing:
> 
> ip add add 1.2.115.157/32 dev eth0
> ip ro del table local 192.168.99.5/32 dev eth0
> ip route add 1.2.115.157/32 dev eth1

... and any application that looks at the local interface addresses
(e.g. ntpd, bind, etc.) will get thoroughly confused. Oh and worst-case
(i don't know/didn't check) source address selection as well.

I'd advise against it.

> instead of:
> 
> ip neigh add proxy 1.2.115.157 dev eth0


-David
