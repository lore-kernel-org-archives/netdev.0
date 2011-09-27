From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 22:37:19 +0200
Message-ID: <1317155839.2472.5.camel@edumazet-laptop>
References: <20110927200328.GA22678@redhat.com>
	 <20110927.160804.528213323197711241.davem@davemloft.net>
	 <20110927201500.GA27713@redhat.com>
	 <20110927.161848.1967387021236457958.davem@davemloft.net>
	 <20110927202405.GB27713@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35167 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab1I0UhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:37:23 -0400
Received: by bkbzt4 with SMTP id zt4so7346814bkb.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 13:37:22 -0700 (PDT)
In-Reply-To: <20110927202405.GB27713@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 16:24 -0400, Dave Jones a =C3=A9crit =
:
> On Tue, Sep 27, 2011 at 04:18:48PM -0400, David Miller wrote:
>  > From: Dave Jones <davej@redhat.com>
>  > Date: Tue, 27 Sep 2011 16:15:00 -0400
>  >=20
>  > > It looks like it died in put_page..
>  > >=20
>  > > <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
>  > >=20
>  > > which is only called in one place..
>  > >=20
>  > > 1267         for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  > > 1268                 if (skb_shinfo(skb)->frags[i].size <=3D eat=
) {
>  > > 1269                         put_page(skb_shinfo(skb)->frags[i].=
page);
>  > > 1270                         eat -=3D skb_shinfo(skb)->frags[i].=
size;
>  > > 1271                 } else {
>  >=20
>  > That's a pretty serious corruption, all frag array entries from 0 =
to
>  > nr_frags should have valid, non-NULL page pointers.
>  >=20
>  > Maybe a LRO/GRO bug?  There were a couple of those.
>=20
> I'll see if I can talk him into trying a self-built kernel, as we're =
not
> rebasing f14 at this point in its life-cycle. If it turns out to stil=
l affect
> 3.x, I'll bring it up again.
>=20

This could be a struct skb_shared_info -> nr_frags corruption

(Something was overflowing skb head and overflowing very beginning of
skb_shared_info in rare circumstances)

We had such bug in the past, I cant remember details right now.
