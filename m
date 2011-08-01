From: Alan Cox <alan@linux.intel.com>
Subject: Re: [net-next v2 02/71] 3c*/acenic/typhoon: Move 3Com Ethernet
 drivers
Date: Mon, 1 Aug 2011 10:03:03 +0100
Message-ID: <20110801100303.48ed75f7@bob.linux.org.uk>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	Donald Becker <becker@scyld.com>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	David Hinds <dahinds@users.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36031 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab1HAJAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 05:00:17 -0400
In-Reply-To: <1312082850-24914-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Jul 2011 20:26:21 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> necessary Kconfig and Makefile changes.

This still seems crazy

The 3c503 is not being moved (as its 8390 based)

But the 3c505/3c523/3c527/3c507 by that logic also shouldn't be moved
as really they all belong with the rest of the Intel devices they are
basically variants of (the 3c527 is weirder, in fact you can probably
run CP/M 86 on it if you were mad enough)

>  drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c |    0
>  drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c |    0

These are currently sensibly where they belong - with the pcmcia
adapters.

>  drivers/net/{ => ethernet/3com}/3c59x.c          |    0
>  drivers/net/ethernet/3com/Kconfig                |  200
> ++++++++++++++++++++++
> drivers/net/ethernet/3com/Makefile               |   16 ++
> drivers/net/{ => ethernet/3com}/acenic.c         |    0
> drivers/net/{ => ethernet/3com}/acenic.h         |    0

And most Acenic devices are probably branded Netgear not 3COM and may
also claim to be from Farallon, SGI, Alteon or DEC. Again not a 3Com
originated part.

So I still think this patch is utter nonsense and just noise.

There isn't any sense in trying to line the network drivers up by
whatever is written on the box that was thrown away years before. The
reality is that most cards do not bear anything relevant to the chipset
vendors name, even by the early 1990s. 

Architectually it makes more sense to keep tidy by bus type and by
chipset, not by vendor name

NAK

And even if you wanted to make Kconfig simpler - you don't need to move
files around.

Alan
