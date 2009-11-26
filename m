From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Thu, 26 Nov 2009 15:37:45 -0800 (PST)
Message-ID: <20091126.153745.115170133.davem@davemloft.net>
References: <4AE92F4D.6070101@gmail.com>
	<20091029.010009.175904855.davem@davemloft.net>
	<alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kolo@albatani.cz, bugzilla-daemon@bugzilla.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753331AbZKZXh0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2009 18:37:26 -0500
In-Reply-To: <alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)

> How about this then... Does the original reporter have NFS in use?
>=20
> [PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)

I must be getting old and senile, but I specifically remembered that
we prevented a socket from ever being bound again once it has been
bound one time specifically so we didn't have to deal with issues
like this.

I really don't think it's valid for NFS to reuse the socket structure
like this over and over again.  And that's why only NFS can reproduce
this, the interfaces provided userland can't actually go through this
sequence after a socket goes down one time all the way to close.

Do we really want to audit each and every odd member of the socket
structure from the generic portion all the way down to INET and
TCP specifics to figure out what needs to get zero'd out?

So much relies upon the one-time full zero out during sock allocation.

Let's fix NFS instead.
