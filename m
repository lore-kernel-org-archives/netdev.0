From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: use jump_label to shortcut RPS if not
 setup
Date: Thu, 17 Nov 2011 23:19:16 +0100
Message-ID: <1321568356.2444.7.camel@edumazet-laptop>
References: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321565689.2444.5.camel@edumazet-laptop>
	 <20111117.170442.1731100546322591134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60207 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab1KQWTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 17:19:21 -0500
Received: by wwe5 with SMTP id 5so3864330wwe.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 14:19:20 -0800 (PST)
In-Reply-To: <20111117.170442.1731100546322591134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 17:04 -0500, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 17 Nov 2011 22:34:49 +0100
>=20
> > I wonder if we could use this jump_label infrastructure to shortcut
> > expensive netfilter nf_hook_slow() / nf_iterate on empty
> > tables/chains...
>=20
> That would be nice, I can't see why it wouldn't be possible.

Almost done :)

Only problem is arch_static_branch() has a "i" (key), so some calls won=
t
be optimized (hooknum in a variable, not a constant)

for example in nf_ct_frag6_output()

Not a big deal, most calls can be optimized away.
