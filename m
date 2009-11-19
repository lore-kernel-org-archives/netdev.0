From: David Miller <davem@davemloft.net>
Subject: Re: Network hangs with 2.6.30.5
Date: Thu, 19 Nov 2009 15:40:38 -0800 (PST)
Message-ID: <20091119.154038.194307613.davem@davemloft.net>
References: <20090907072143.GA5966@ff.dom.local>
	<20091001.154913.88345178.davem@davemloft.net>
	<alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, holger.hoffstaette@googlemail.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, zbr@ioremap.net
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59005
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758155AbZKSXkW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 18:40:22 -0500
In-Reply-To: <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 2 Oct 2009 11:11:55 +0300 (EEST)

> On Thu, 1 Oct 2009, David Miller wrote:
>=20
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Mon, 7 Sep 2009 07:21:43 +0000
>>=20
>> I also looked through all the TCP commits in 2.6.29 to 2.6.30
>> and I could not find anything else that might cause stalls with
>> time-wait recycled connections.
>=20
> What about the more than 64k connections change a9d8f9110d7e953c2f2 (=
or=20
> its fixes), it might be another possibility? ...It certainly does=20
> something related to reuse and happens to be in the correct time fram=
e...=20
> (I've added Evgeniy).

So I've been studying this one quite a bit.

This change could only cause problems in timewait recycling if it:

1) Would accept using a bind bucket that previously it would not

2) Caused socket corruption due to bad locking

And I can find neither problem with the Evgeniy's bind changes.

So we've back to square one I think.
