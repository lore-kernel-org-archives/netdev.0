From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 12:33:19 -0800
Message-ID: <1447965199.22599.252.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119195419.GA6728@ast-mbp.thefacebook.com>
	 <1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87oaepzqq2.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36110 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161238AbbKSUdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:33:21 -0500
Received: by pacdm15 with SMTP id dm15so91592429pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:33:20 -0800 (PST)
In-Reply-To: <87oaepzqq2.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 21:20 +0100, Bj=C3=B8rn Mork wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > How many times should we crash before napi_frags_skb() returns NULL=
 ?
> ..
> >                         return NULL;
>=20
> Huh?  Now I'm lost here, too.


Well, Ethernet drivers should not feed GRO with frames with less than 1=
4 bytes.

( eth_type_trans() would crash the same )

Lets fix buggy drivers instead of adding defensive code all over the st=
ack.

napi_gro_frags() is used by exactly 10 drivers, and I am pretty sure th=
ey are OK.
