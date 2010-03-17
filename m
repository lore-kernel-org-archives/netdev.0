From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 11:47:17 -0700 (PDT)
Message-ID: <20100317.114717.30960972.davem@davemloft.net>
References: <40ec3ea41003171120x26d2e8b4q6b59c992ab28e454@mail.gmail.com>
	<20100317.112706.143765408.davem@davemloft.net>
	<40ec3ea41003171144s6acbf2fdl4434f2147b8244a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: chase.douglas@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52423
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754132Ab0CQSq4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 14:46:56 -0400
In-Reply-To: <40ec3ea41003171144s6acbf2fdl4434f2147b8244a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Chase Douglas <chase.douglas@canonical.com>
Date: Wed, 17 Mar 2010 14:44:30 -0400

> On Wed, Mar 17, 2010 at 2:27 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Chase Douglas <chase.douglas@canonical.com>
>> Date: Wed, 17 Mar 2010 14:20:45 -0400
>>
>>> If that's the case, what's the solution? It's not safe to call
>>> disable_irq* in softirq context anymore.
>>
>> That's a huge problem, because such a restriction has broken
>> several drivers. =A03c59x is not the only one which uses this
>> technique for this reason. =A0The 8390 one does too.
>=20
> So basically the answer right now is: it's broken and needs to be
> reworked, and a switch to disabling irqs is deemed inadequate. Is tha=
t
> accurate?

Yep.  The bug is whatever caused disable_irq*() to stop working
where these drivers have been using it for what feels like
a century :-)
