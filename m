From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Tue, 19 Mar 2013 05:25:58 -0700
Message-ID: <1363695958.21184.42.camel@edumazet-glaptop>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	 <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	 <1363651672.21184.17.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	 <CANP3RGehbKbh1ambT-RQQqfOkovzySB4_CWg+LPdJV7yDkYBCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:40318 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab3CSM0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 08:26:01 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so390254pbc.9
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 05:26:01 -0700 (PDT)
In-Reply-To: <CANP3RGehbKbh1ambT-RQQqfOkovzySB4_CWg+LPdJV7yDkYBCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please Maciej do not top post on lkml or netdev mailing lists.

On Tue, 2013-03-19 at 02:18 -0700, Maciej =C5=BBenczykowski wrote:
> Can the HW calculate and return a 1s complement sum of the entire
> packet (or a large portion there-of)?
> Fixing that up to be only of the outer IPv4, inner IPv4 and inner TCP
> relevant portions should still be simpler (well faster) than
> calculating the TCP checksum.
> I'm pretty sure that some relationship between 1s complement sum of
> all bytes, outer IPv4 checksum, inner IPv4 checksum and TCP checksum
> could be pulled out of a hat with some deeper thought.  (similarly fo=
r
> IPv4/GRE/IPv6/TCP and other combinations)
>=20
> What portions of the packet can the HW/FW [partially] checksum - and
> return the value to the driver for further processing?
> Can it return 1s complement sum of data portion of outer IPv4 (ie. in
> IPv4/GRE/IPv4/TCP return a 1s complement sum of GRE/IPv4/TCP bytes)
>=20

I assume Dmitry was speaking of this possibility, and our stack should
handle this just fine.

NIC providing these kind of checksums set :

skb->ip_summed =3D CHECKSUM_COMPLETE;
skb->csum =3D csum;

before feeding the packet to the stack.

When we pull some header, we have to call skb_postpull_rcsum()
to adjust the skb->csum so that final check can be done.

About 20 drivers currently provide these kind of checksumming.
