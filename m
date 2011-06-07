From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: prevent information leak
Date: Tue, 07 Jun 2011 07:38:39 +0200
Message-ID: <1307425119.2642.63.camel@edumazet-laptop>
References: <1307422939.2642.57.camel@edumazet-laptop>
	 <20110606.222416.1114593259198630297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65176 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab1FGFio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:38:44 -0400
Received: by wwa36 with SMTP id 36so4535342wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 22:38:43 -0700 (PDT)
In-Reply-To: <20110606.222416.1114593259198630297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 22:24 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 07 Jun 2011 07:02:19 +0200
>=20
> > In 2.6.27, commit 393e52e33c6c2 (packet: deliver VLAN TCI to usersp=
ace)
> > added a small information leak.
> >=20
> > Add padding field and make sure its zeroed before copy to user.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Patrick McHardy <kaber@trash.net>
>=20
> I fear this will change the size of these structures on some weird
> architecture.  Doesn't ARM, for example, have weird rules
> wrt. alignment and structure sizing when "smaller than word" elements
> are involved?
>=20
> That's why we need __packed on:
>=20
> struct nd_opt_hdr {
> 	__u8		nd_opt_type;
> 	__u8		nd_opt_len;
> } __packed;
>=20
> for example.
>=20
> Probably safe to just do a memset of the tail, and the constant lengt=
h
> will evaluate to zero on these weird platforms.  On others, where the
> padding does matter, the memset will emit the same code as your new
> assignments do.

It should not matter for these structures, or 393e52e33c6c2 would have
break applications on all arches (not only ARM), since it enlarged them
without any warning ;)




