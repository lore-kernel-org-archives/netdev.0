From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 7 May 2010 10:36:39 -0700
Message-ID: <20100507103639.4f1a51fa@nehalam>
References: <1273085598.2367.233.camel@edumazet-laptop>
	<i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273147586.2357.63.camel@edumazet-laptop>
	<20100506.220443.135536330.davem@davemloft.net>
	<1273210329.2222.42.camel@edumazet-laptop>
	<20100507101451.1b4286b7@nehalam>
	<1273252893.2261.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50133 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971Ab0EGRgn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 13:36:43 -0400
In-Reply-To: <1273252893.2261.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 May 2010 19:21:33 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 07 mai 2010 =E0 10:14 -0700, Stephen Hemminger a =E9crit =
:
>=20
> > Forget the per cpu data; the pool should just be scrapped.
> >=20
> > The only reason the pool exists is that the crypto hash state which
> > should just be moved into the md5_info (88 bytes).  The pseudo
> > header can just be generated on the stack before passing to the cry=
pto
> > code.
>=20
>=20
> Sure, but I'm afraid there is no generic API do do that (if we want t=
o
> reuse crypto/md5.c code).

It looks like the pool is just an optimization to avoid opening too
many crypto API connections.  This should only be an issue if offloadin=
g
MD5.
