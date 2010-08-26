From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 10:34:43 +0200
Message-ID: <1282811683.2476.133.camel@edumazet-laptop>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
	 <1282806640.3469.26.camel@localhost.localdomain>
	 <1282809788.2476.59.camel@edumazet-laptop>
	 <1282810448.12544.3200.camel@zakaz.uk.xensource.com>
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
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59020 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab0HZIes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 04:34:48 -0400
Received: by wwb28 with SMTP id 28so1301552wwb.1
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 01:34:47 -0700 (PDT)
In-Reply-To: <1282810448.12544.3200.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 09:14 +0100, Ian Campbell a =C3=A9cri=
t :
> On Thu, 2010-08-26 at 09:03 +0100, Eric Dumazet wrote:
> > Here is the patch, could you test it please ?
> >=20
> > Thanks !
> >=20
> > [PATCH] l2tp: test for malicious frames in l2tp_eth_dev_recv()
> >=20
> > close https://bugzilla.kernel.org/show_bug.cgi?id=3D16529
> >=20
> > Before calling dev_forward_skb(), we should make sure skb contains =
at
> > least an ethernet header, even if length included in upper layer sa=
id
> > so.
>=20
> Does this imply that there is some problem with xen-netfront setting
> skb->len or skb->data_len or something incorrectly? It's not clear wh=
ere
> data_len has come from in this context.

data_len is a 16bit field provided in a prior encapsulation header,
provided by user (untrusted source)

Some buggy or malicious software sent an invalid frame,


< encapsulation [len=3D1000] >  < 'runt' eth frame (len<14) >=20

Another fix would be to change l2tp_recv_dequeue_skb(), and check

L2TP_SKB_CB(skb)->length against skb->len, before calling=20

(*session->recv_skb)(session, skb, length);


I prefer the one liner patch I sent you, as a minimum fix.


