From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 22:06:29 +0200
Message-ID: <1305057989.2437.18.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
	 <1305047682.2758.1.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101226460.2875@router.home>
	 <alpine.DEB.2.00.1105101242420.2875@router.home>
	 <1305050754.2758.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101323290.4023@router.home>
	 <1305055948.2437.13.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101435480.4023@router.home>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62404 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab1EJUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:06:33 -0400
Received: by wya21 with SMTP id 21so4959841wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 13:06:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105101435480.4023@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 14:38 -0500, Christoph Lameter a =C3=A9crit=
 :

> Optimizing? You think about this as concurrency issue between multipl=
e
> cpus. That is fundamentally wrong. This is dealing with access to per=
 cpu
> data and the concurrency issues are only with code running on the *sa=
me*
> cpu.
>=20

If you enable irqs, then this object can be allocated by _this_ cpu and
given to another one.

Another cpu can free the page, forcing you to call a very expensive
function, that might give obsolete result as soon it returns.

Maybe I am just tired tonight, this seems very obvious, I must miss
something.



