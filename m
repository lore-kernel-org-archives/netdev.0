From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Tue, 08 Mar 2011 22:44:37 +0100
Message-ID: <4D76A345.9040200@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com> <20110308071350.GA2826@psychotron.redhat.com> <20110308134247.GW11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52509 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795Ab1CHVol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 16:44:41 -0500
Received: by wya21 with SMTP id 21so402658wya.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:44:39 -0800 (PST)
In-Reply-To: <20110308134247.GW11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
> I'm pretty sure this patch will have the same catastrophic problem yo=
ur
> last one did.  By cloning and setting skb2->dev =3D orig_dev you just
> inserted a frame identical to the one we received right back into the
> stack.  It only took a few minutes for my box to melt as one frame on
> the wire will cause an infinite number of frames to be received by th=
e
> stack.

I agree with Andy. We still keep one reinject (netif_rx), which is prob=
ably better that two=20
(__netif_receive_skb), but not enough.

I really think we need a general framework for late delivery of final p=
ackets to packet handler=20
registered somewhere in the rx_handler path.

Jiri, is this patch the one you announced as "I have some kind nice sol=
ution in mind and I'm going=20
to submit that as a patch later (too many patches are in the wind atm)"=
 ?
