From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 09:55:41 +0100
Message-ID: <1282812941.12544.3246.camel@zakaz.uk.xensource.com>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
	 <1282806640.3469.26.camel@localhost.localdomain>
	 <1282809788.2476.59.camel@edumazet-laptop>
	 <1282810448.12544.3200.camel@zakaz.uk.xensource.com>
	 <1282811683.2476.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"heil@terminal-consulting.de" <heil@terminal-consulting.de>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36232 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246Ab0HZIzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 04:55:45 -0400
In-Reply-To: <1282811683.2476.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-26 at 09:34 +0100, Eric Dumazet wrote:
> Le jeudi 26 ao=C3=BBt 2010 =C3=A0 09:14 +0100, Ian Campbell a =C3=A9c=
rit :
> > On Thu, 2010-08-26 at 09:03 +0100, Eric Dumazet wrote:
> > > Here is the patch, could you test it please ?
> > >=20
> > > Thanks !
> > >=20
> > > [PATCH] l2tp: test for malicious frames in l2tp_eth_dev_recv()
> > >=20
> > > close https://bugzilla.kernel.org/show_bug.cgi?id=3D16529
> > >=20
> > > Before calling dev_forward_skb(), we should make sure skb contain=
s at
> > > least an ethernet header, even if length included in upper layer =
said
> > > so.
> >=20
> > Does this imply that there is some problem with xen-netfront settin=
g
> > skb->len or skb->data_len or something incorrectly? It's not clear =
where
> > data_len has come from in this context.
>=20
> data_len is a 16bit field provided in a prior encapsulation header,
> provided by user (untrusted source)
>=20
> Some buggy or malicious software sent an invalid frame,
>=20
>=20
> < encapsulation [len=3D1000] >  < 'runt' eth frame (len<14) >=20
>=20
> Another fix would be to change l2tp_recv_dequeue_skb(), and check
>=20
> L2TP_SKB_CB(skb)->length against skb->len, before calling=20
>=20
> (*session->recv_skb)(session, skb, length);
>=20
>=20
> I prefer the one liner patch I sent you, as a minimum fix.

Thanks, I just wanted to be sure we weren't papering over a potential
issue in xen-netfront.

Ian.


