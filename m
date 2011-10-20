From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 15:51:22 +0200
Message-ID: <1319118682.7735.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
	 <1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
	 <4EA01E77.8040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	davem@davemloft.net, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jonsmirl@gmail.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63695 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab1JTNv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 09:51:27 -0400
Received: by wwe6 with SMTP id 6so4204571wwe.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 06:51:26 -0700 (PDT)
In-Reply-To: <4EA01E77.8040300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 17:13 +0400, Dmitry Eremin-Solenikov a
=C3=A9crit :
> Hi, Alexander, colleagues,
>=20
> On 10/20/2011 04:50 PM, Alexander Smirnov wrote:
> > Hi Eric,
> >
> > thank you for the replies. And another question I forgot to ask:
> >
> > when I send fragments, I still have original skb buffer. What shoul=
d I
> > do with it, is there any
> > "proper/good" ways to drop it? Because I've already fragmented it a=
nd
> > do not need to send
> > original skb to queue.
>=20
> You might want to check the TCP/IP fragmentation code path. I think y=
ou=20
> can drop it with kfree_skb, but I ain't sure ATM.

In the TCP/IP frag code path, we own the skb and can do many things,
like using the skb to store one of the fragment.

In a driver ndo_start_xmit(), things are a bit different.

Special care must be taken if skb_cloned(skb) is true...
