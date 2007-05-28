From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: forcedeth: Reside in 100Mbit Kconfig but also supports 1000Mbit cards
Date: Mon, 28 May 2007 22:02:56 +0200
Message-ID: <m3ejl0u367.fsf@maximus.localdomain>
References: <20070526230750.GA9566@datenfreihafen.org>
	<20070526172929.755b8d98.randy.dunlap@oracle.com>
	<20070527005609.GB9566@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>, aabdulla@nvidia.com,
	netdev@vger.kernel.org
To: Stefan Schmidt <stefan@datenfreihafen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33034 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020AbXE2DiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 23:38:14 -0400
In-Reply-To: <20070527005609.GB9566@datenfreihafen.org> (Stefan Schmidt's message of "Sun, 27 May 2007 02:56:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Schmidt <stefan@datenfreihafen.org> writes:

> I still like the partition by speed.

Me 2

> It makes it a lot easier to find
> the right driver in the bunch of available ones.

Sure. Unless you have a 100 Mb/s card and you don't know the same
driver works with newer 1000 Mb/s models.

IOW - questionable.

> A solution like a
> Kconfig entry symlink for driver which needs to support cards in two
> or more categories would be my favorite.

It would be a total mess.


However, some clever conditionals could make it better.
One menu for both 100 and 1000 Mb/s, and something like:

tristate 100Mbps (Y/N/M)
tristate 1000Mbps (Y/N/M)

...
if 100Mbps
	Realtek 8139
	Intel E100
fi

if 100Mbps || 1000Mbps
	forcedeath
	some_SIS_driver
	etc.
fi

if 1000Mbps
	E1000
	...

Probably 10 Mbps drivers could lead the list. You could check for PCI,
ISA and what not.
This way each driver has only one entry, but if you know you have,
say, 1 Gb/s Ethernet card only you can select 1 Gb/s and don't
worry about 100-Mbps NVidias.

I'd include that Tulip thing, too - no need for a separate menu
(the directory is a different thing).
-- 
Krzysztof Halasa
