From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH] Do not register ne2k-pci device until initialized
Date: Sat, 2 May 2009 19:58:11 +0200
Message-ID: <20090502175811.GA26635@rhlx01.hs-esslingen.de>
References: <49FC7D5E.6050203@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:34741 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756498AbZEBR6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 13:58:13 -0400
Content-Disposition: inline
In-Reply-To: <49FC7D5E.6050203@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Good spotting, that fixes a clear startup race

I saw this and thought that this must be one of those non-singular bugs
again... ;)

(I checked for dev_addr manipulations _after_ register_netdev)

And, well...:

smsc911x.c looks like it has the same issue (in case of a non-specified
MAC address - invalid EEPROM content).

Dito ucc_geth.c

Dito arm/ixp4xx_eth.c

Dito wireless/netwave_cs.c


Given that several drivers seem to violate this rule: is there a way
to add a check against this problem?

Andreas Mohr
