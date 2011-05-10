From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 15:33:31 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101531160.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
  <1305050754.2758.12.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101323290.4023@router.home>  <1305055948.2437.13.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101435480.4023@router.home> <1305057989.2437.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-993618346-1305059613=:4023"
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.prem.mail.ac4.yahoo.com ([76.13.13.40]:34407 "HELO
	smtp101.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750950Ab1EJUdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:33:35 -0400
In-Reply-To: <1305057989.2437.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-993618346-1305059613=:4023
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 10 May 2011, Eric Dumazet wrote:

> Le mardi 10 mai 2011 =C3=A0 14:38 -0500, Christoph Lameter a =C3=A9crit :
>
> > Optimizing? You think about this as concurrency issue between multiple
> > cpus. That is fundamentally wrong. This is dealing with access to per c=
pu
> > data and the concurrency issues are only with code running on the *same=
*
> > cpu.
> >
>
> If you enable irqs, then this object can be allocated by _this_ cpu and
> given to another one.

That will cause an incrementing of the tid.

> Another cpu can free the page, forcing you to call a very expensive
> function, that might give obsolete result as soon it returns.

No the other cpu cannot free the page since the page is pinned by
the current cpu (see PageFrozen()).

> Maybe I am just tired tonight, this seems very obvious, I must miss
> something.

Yeah you are way off thinking about cpu to cpu concurrency issues that do
not apply here.



---1463811839-993618346-1305059613=:4023--
