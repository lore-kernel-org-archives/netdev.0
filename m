From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 09:22:34 +0200
Message-ID: <1282807354.2681.946.camel@edumazet-laptop>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
	 <1282806640.3469.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"heil@terminal-consulting.de" <heil@terminal-consulting.de>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41568 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239Ab0HZHWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 03:22:42 -0400
Received: by wwb28 with SMTP id 28so1207189wwb.1
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 00:22:41 -0700 (PDT)
In-Reply-To: <1282806640.3469.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 08:10 +0100, Ian Campbell a =C3=A9cri=
t :
> On Wed, 2010-08-25 at 23:56 +0100, Jeremy Fitzhardinge wrote:
>=20
> > >> Here is a link for the setup
> > >> http://www.pastebin.org/445975
> > >> and here a link with more details about the crash http://pastebi=
n.org/449221
> >=20
> > Please attach these to the bug or something; pastebin is not workin=
g for
> > me at the moment.
>=20
> It's really slow for me but got there eventually. I've attached the
> files.
>=20
> It's apparently hitting this BUG_ON in __skb_pull:
>        =20
>         static inline unsigned char *__skb_pull(struct sk_buff *skb, =
unsigned int len)
>         {
>                 skb->len -=3D len;
>                 BUG_ON(skb->len < skb->data_len);
>                 return skb->data +=3D len;
>         }
>=20
> Ian.
>=20

Thanks a lot.

I'll submit a patch to fix l2tp_eth_dev_recv()=20

Its illegal to call dev_forward_skb() with a too small payload.



