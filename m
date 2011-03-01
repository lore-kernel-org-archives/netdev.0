From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 14:03:29 +0100
Message-ID: <1298984609.3284.98.camel@edumazet-laptop>
References: <20110228141322.GF9763@canuck.infradead.org>
	 <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37884 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab1CANDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:03:34 -0500
Received: by fxm17 with SMTP id 17so4765322fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 05:03:33 -0800 (PST)
In-Reply-To: <20110301115305.GA6984@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 19:53 +0800, Herbert Xu a =C3=A9crit :
> On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:
> >
> > CPU 11 handles all TX completions : Its a potential bottleneck.
> >=20
> > I might ressurect XPS patch ;)
>=20
> Actually this has been my gripe all along with our TX multiqueue
> support.  We should not decide the queue based on the socket, but
> on the current CPU.
>=20
> We already do the right thing for forwarded packets because there
> is no socket to latch onto, we just need to fix it for locally
> generated traffic.
>=20

I believe its now done properly (in net-next-2.6) with commit
4f57c087de9b46182 (net: implement mechanism for HW based QOS)

> The odd packet reordering each time your scheduler decides to
> migrate the process isn't a big deal IMHO.  If your scheduler
> is constantly moving things you've got bigger problems to worry
> about.

Well, BENET has one TX queue anyway...


