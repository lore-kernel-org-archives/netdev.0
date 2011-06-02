From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 13:46:37 -0700 (PDT)
Message-ID: <20110602.134637.1101638217263464114.davem@davemloft.net>
References: <20110602194621.GB2749@hmsreliant.think-freely.org>
	<20110602.130448.917724318321380583.davem@davemloft.net>
	<4DE7EF05.8030505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab1FBUr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:47:58 -0400
In-Reply-To: <4DE7EF05.8030505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Thu, 02 Jun 2011 22:13:57 +0200

> To be more precise, due to the way bonding use queue mapping for slav=
e
> selection, it is desirable to clear the mapping before sending to the
> slave, because the meaning of the mapping for the slave interface
> might be really different from the meaning for the bonding
> interface. Arguably, this is the mapping usage in bonding which is
> "different" from other usages, but...

This just confirms my reasoning behind why I wanted to discourage
drivers from providing explicit ->ndo_select_queue() methods unless
absolutely necessary.

Information now gets lost in cases like this bonding issue.

Bonding should definitely, as I suggested, remember the original
rxhash value and restore it when sending to the slave.
