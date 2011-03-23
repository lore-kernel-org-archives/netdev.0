From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_fragment:kernel may panic when replay big packet
 with RST flag
Date: Wed, 23 Mar 2011 12:01:56 +0100
Message-ID: <1300878116.3063.101.camel@edumazet-laptop>
References: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Feng Gao <kernel.goter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48361 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab1CWLCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 07:02:00 -0400
Received: by yxs7 with SMTP id 7so3271623yxs.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 04:01:59 -0700 (PDT)
In-Reply-To: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 mars 2011 =C3=A0 18:49 +0800, Feng Gao a =C3=A9crit :
> Hello everyone:
>=20
> PC(A)-linux(B)-PC(C)
> computer(linux B) with two net interface,eth0 and eth1.
> PC(A) send syn to PC(C)  though linux B.
> then PC(C) replay a big packet  with RST flag(use tcpsic or other too=
ls).
>=20
> This RST packet(1480) come in from eth0(mtu 1500) and go out from
> eth1(mtu 700), so this RST packet should fragment.
>=20
> BUT in tcp_packet func: if the connection has no reply packet,and
> receive the RST packet.ip_conntrack should  destroy.
>   if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>                 /* If only reply is a RST, we can consider ourselves =
not to
>                    have an established connection: this is a fairly c=
ommon
>                    problem case, so we can delete the conntrack
>                    immediately.  --RR */
>                 if (th->rst) {
>                         nf_ct_kill_acct(ct, ctinfo, skb);
>                         return NF_ACCEPT;
>                 }
>         }
>=20
> BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
> so when this RST packet goto ip_fragment,ip_fragment call nf_copy, in
> __nf_copy func
> the fragment skb->nfct point to the destory mem.
> dst->nfct =3D src->nfct;
> nf_conntrack_get(src->nfct);
>=20
> SO finally.kfree_skb call destroy_conntrack again. this may result in
> LINUX B kernel panic.
>=20
>=20
> here is the patch,sorry ,i dont know how to use diff to generate patc=
h.
> :-D
>=20

Hi Feng

Oh well, please learn how to do this. If you are able to make such
analysis, you sure can learn how to use diff !!!

What is the version of linux you use ?



