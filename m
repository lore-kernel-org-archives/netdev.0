From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 19:14:42 +0200
Message-ID: <1305047682.2758.1.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr> <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105092241390.6784@tiger>
	 <alpine.DEB.2.00.1105091502260.26839@router.home>
	 <1305016988.2614.6.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63433 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab1EJROr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 13:14:47 -0400
Received: by wya21 with SMTP id 21so4844196wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 10:14:46 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105101133440.2611@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 11:39 -0500, Christoph Lameter a =C3=A9crit=
 :

> #ifdef CONFIG_DEBUG_PAGE_ALLOC
> 	if (illegal_page_alloc-address(object))
> 		goto redo;
> #endif
>=20
> before the cmpxchg should do the trick.
>=20

Again, it wont work...

You can have an IRQ right after the check and before cmpxchg

This interrupt can allocate this block of memory, free it, and unmap
page from memory.

cmpxchg() reads unmapped memory -> BUG



