From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Fri, 23 Oct 2009 18:33:13 +0200
Message-ID: <4AE1DAC9.5040603@imap.cc>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>	 <4AE0ECCE.2020407@imap.cc> <1256304869.12174.20.camel@johannes.local>	 <4AE1BD3D.3020007@imap.cc> <1256308311.12174.38.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	Karsten Keil <isdn@linux-pingi.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:38125 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752535AbZJWQdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:33:15 -0400
In-Reply-To: <1256308311.12174.38.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Johannes Berg schrieb:
> On Fri, 2009-10-23 at 16:27 +0200, Tilman Schmidt wrote:
>> Johannes Berg schrieb:
>>> So you've verified that the entire i4l stack can cope with being ca=
lled
>>> twice on the same CPU, from different contexts?
>> What makes you think so?
>=20
> I thought I'd explained this in my other email. *sigh*
[snip]

Ah, I see. You misunderstood my posting. I did not propose that
patch as a definitive and verified solution, but rather as a
request for comments from the people who know and maintain the
code in question. I thought that was clear from the facts that
- - I didn't include "[PATCH]" in the subject line
- - I didn't add a "Signed-off-by" line
- - I wrote "fixed the messages", not "solved the problem"
- - I explicitly wrote "Comments?" and "Adding i4l people to CC"

Apparently all that was still not clear enough. Sorry about that.
So let me try to make my concern as explicit as possible:

- - The patch I posted had the effect that the test which reliably
  triggered the local_softirq_pending message before did not do
  so anymore.

- - To me, this seems to indicate that the netif_rx(skb) call in
  line 1177 of source file drivers/isdn/i4l/isdn_ppp.c is indeed
  involved in the problem.

- - Now I'm asking people who know more than myself about the
  ramifications of that message (ie., you) and/or the code I
  narrowed it down to (ie., the ISDN4Linux maintainers - which
  is why I added them to the CC list) to have a look and determine
  how to fix the problem properly.

- - This would of course include, in finis, the verification you
  mistakenly assumed I might have done already.

I hope that's clear enough. If you have any questions, feel free
to ask.

Thanks,
Tilman

- --
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFK4drJQ3+did9BuFsRAmstAJ94UF/LupINlYpjbxzz9xoiN5w34wCfflRz
YfR/fXt3HasrxUSP29REOnE=3D
=3DVQ/C
-----END PGP SIGNATURE-----
