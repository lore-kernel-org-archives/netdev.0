From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Flow classifier proto-dst and TOS (and proto-src)
Date: Mon, 17 Oct 2011 08:09:59 +0200
Message-ID: <1318831799.2500.25.camel@edumazet-laptop>
References: <1318697463.7169.21.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dan Siemon <dan@coverfire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52033 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1JQGKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 02:10:07 -0400
Received: by wyg36 with SMTP id 36so1829201wyg.19
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 23:10:05 -0700 (PDT)
In-Reply-To: <1318697463.7169.21.camel@ganymede>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 15 octobre 2011 =C3=A0 12:51 -0400, Dan Siemon a =C3=A9crit :
> cls_flow.c: flow_get_proto_dst()
>=20
> The proto-dst key returns the destination port for UDP, TCP and a few
> other protocols [see proto_ports_offset()]. For ICMP and IPIP it fall=
s
> back to:
>=20
> return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
>=20
> Since Linux maintains a dst_entry for each TOS value this causes the
> returned value to be affected by the TOS which is unexpected and
> probably broken.

Hi Dan

I think Patrick did this on purpose, because of of the lack of
perturbation in cls_flow.c : If all these frames were mapped to a singl=
e
flow, they might interfere with an other regular flow and hurt it.

I dont qualify existing code as buggy. Its about fallback behavior
anyway (I dont think its even documented)

If you have too many frames going to the fallback, then this classifier
is probably not the one you should use ?

Hint : You can change your filter to use this classifier only on TCP/UD=
P
trafic, and use another one on other protocols : Coupled to your qdisc
rules, you even can limit to X percent the bandwidth allocated to this
trafic

We could argue that if TOS value of two packets is different, then
packets belong to different flows as well. [ It seems we currently lack
a FLOW_KEY_TOS : that could be a usefull addition ]
