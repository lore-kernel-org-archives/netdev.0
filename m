From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Tue, 09 Aug 2011 10:06:13 +0200
Message-ID: <1312877173.2371.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
	 <CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
	 <20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
	 <20110809.004123.2080217558650594315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49509 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab1HIIGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:06:16 -0400
Received: by wwf5 with SMTP id 5so2377272wwf.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 01:06:15 -0700 (PDT)
In-Reply-To: <20110809.004123.2080217558650594315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 00:41 -0700, David Miller a =C3=A9cri=
t :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 8 Aug 2011 11:19:17 -0700
>=20
> > On Mon, 8 Aug 2011 11:01:57 -0700
> > Tom Herbert <therbert@google.com> wrote:
> >=20
> >> > Since transmit completion means calling dev_kfree_skb() why not =
account
> >> > there? You could add some info to netdev if necessary to get com=
pile
> >> > the statistics.
> >> >
> >> The algorithm depends on knowing the total number of packets compe=
ted
> >> in a single execution of transmit completion (epic based).  We onl=
y
> >> want to recalculate the limits once per completion, which happens =
when
> >> the completion function is called.
> >=20
> > So just add some stats to netdev and count the number of dev_kfree_=
skb
> > calls and do your work at napi complete.
>=20
> No, I think what Tom's doing here is reasonable.
>=20
> First off, drivers have never been required to do specific things if
> they return success for ->ndo_start_xmit().  They can kfree_skb(skb)
> and return NET_TX_SUCCESS, and that's fine.
>=20
> This mean we can't use ->ndo_start_xmit() return values to drive the
> BQL engine.
>=20
> So we simply have a way for the driver to say when it really does
> queue up a packet, and that might be useful for other things.
>=20
> Second, you absolutely do not want to run the BQL engine on every
> single dev_kfree_skb() call.  You want to batch it, and that's what
> Tom's new interface does, and that is therefore quite reasonable
> too.
>=20
> In fact, I think the best part about this revision of the BQL patches
> is the device driver interface. :-)
>=20

I agree, it permits a smooth transition to selected drivers, even some
non NAPI ones ;)

In some stress situations, NAPI never completes, so it would also mean
adding a dql call in this case...



