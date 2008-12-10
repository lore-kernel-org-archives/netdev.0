From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: ensure GPRS device does not go away during
 TX work
Date: Wed, 10 Dec 2008 15:28:45 -0800 (PST)
Message-ID: <20081210.152845.24693255.davem@davemloft.net>
References: <200812101514.56827.remi.denis-courmont@nokia.com>
	<1228914929-26337-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbYLJX2o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 18:28:44 -0500
In-Reply-To: <1228914929-26337-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 10 Dec 2008 15:15:28 +0200

> We need to hold the device while TX work is pending, as work is flush=
ed
> only after the network device is unregistered.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

This seems unnecessary.

If you simply create proper ->open and ->stop methods for the GPRS net
device you can purge the TX queue in ->stop() and avoid this
refcounting business.
