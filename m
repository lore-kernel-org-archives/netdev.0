From: David Miller <davem@davemloft.net>
Subject: Re: GRO with non napi driver: BUG in __napi_complete
Date: Fri, 27 Mar 2009 15:50:38 -0700 (PDT)
Message-ID: <20090327.155038.247597952.davem@davemloft.net>
References: <49BF60C9.1080100@linux.vnet.ibm.com>
	<20090317102244.GB23396@gondor.apana.org.au>
	<65634d660903271205v2c82469en6d71e08077202900@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbZC0Wuu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 18:50:50 -0400
In-Reply-To: <65634d660903271205v2c82469en6d71e08077202900@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Fri, 27 Mar 2009 12:05:30 -0700

> > On the legacy netif_rx path, I incorrectly tried to optimise
> >
> > the napi_complete call by using __napi_complete before we reenable
> > IRQs. =A0This simply doesn't work since we need to flush the held
> > GRO packets first.
> >
> > This patch fixes it by doing the obvious thing of reenabling
> > IRQs first and then calling napi_complete.
>=20
> Does this fix generate a race condition for a non-NAPI device?=A0 If
> netif_rx runs immediately after local_irq_enable it would queue a
> packet on the backlog queue and try to schedule napi (the latter has
> no effect because napi has not completed).=A0 On return from interrup=
t,
> napi_complete is done leaving a packet in the input queue but napi is
> not scheduled to process it.

Yes we know this version of Herbert's patch has that problem,
read the rest of the thread and subsequent versions of the fix.
