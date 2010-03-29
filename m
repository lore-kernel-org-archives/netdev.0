From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 15:20:13 +0300
Message-ID: <4BB09AFD.4050304@iki.fi>
References: <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi> <20100329115701.GA24367@gondor.apana.org.au> <4BB0970E.7060405@iki.fi> <20100329121124.GA24470@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:65161 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab0C2MUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:20:18 -0400
Received: by ewy20 with SMTP id 20so668127ewy.1
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 05:20:15 -0700 (PDT)
In-Reply-To: <20100329121124.GA24470@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 03:03:26PM +0300, Timo Ter=E4s wrote:
>> All of the code treats the walk.dead as a hint. It does not need
>> strong synchronization with a lock.
>=20
> Well then converting it to an atomic_t is completely pointless.

Yes, I came to same conclusion. The only thing I thought justifying
it, was the xfrm_policy_kill() doing the check of the old value.

But as noted few mails ago, it's not necessary. So I'll just go
ahead and remove all locking from the read side, and move the
xfrm_policy_kill to use plain write.
