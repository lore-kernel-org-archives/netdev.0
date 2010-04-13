From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 18:52:09 +0200
Message-ID: <4BC4A139.3010605@siemens.com>
References: <20100413145944.GA7716@redhat.com>	 <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:17266 "EHLO david.siemens.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063Ab0DMQwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 12:52:51 -0400
In-Reply-To: <1271176838.16881.537.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 13 avril 2010 =C3=A0 17:36 +0200, Jan Kiszka a =C3=A9crit :
>> Michael S. Tsirkin wrote:
>>> The following situation was observed in the field:
>>> tap1 sends packets, tap2 does not consume them, as a result
>>> tap1 can not be closed.
>> And before that, tap1 may not be able to send further packets to any=
one
>> else on the bridge as its TX resources were blocked by tap2 - that's
>> what we saw in the field.
>>
>=20
> After the patch, tap1 is able to flood tap2, and tap3/tap4 not able t=
o
> send one single frame. Is it OK ?

I think if that's a real issue, you have to apply traffic shaping to th=
e
untrusted nodes. The existing flow-control scheme was fragile anyway as
you had to translate packet lengths on TX side to packet counts on RX.

Jan

--=20
Siemens AG, Corporate Technology, CT T DE IT 1
Corporate Competence Center Embedded Linux
