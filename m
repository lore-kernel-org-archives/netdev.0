From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] xfrm: Fix double dst_release() in xfrm_lookup()
 -EREMOTE case
Date: Thu, 8 Apr 2010 14:43:31 +0100
Message-ID: <20100408134331.GC30647@rakim.wolfsonmicro.main>
References: <1270729773-1758-1-git-send-email-broonie@opensource.wolfsonmicro.com>
 <4BBDCE8A.7040106@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:40791 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758468Ab0DHNnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 09:43:33 -0400
Content-Disposition: inline
In-Reply-To: <4BBDCE8A.7040106@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 03:39:38PM +0300, Timo Ter=E4s wrote:
> Mark Brown wrote:

> >I'm not sure if this is correct or not - there may a reference been
> >taken earlier in __xfrm_lookup() that's being dropped but I didn't s=
pot
> >it.

> This is not correct.

So I was correct when I said that there might've been a reference taken
earlier :)

> This semantics is important because __xfrm_lookup() is also called
> from other places, that do other things when they get -EREMOTE.

Right, it was the fact that this was the only place doing the free that
made this unclear.  Some comments might make this rather more obvious,
the fact that the release was added to __xfrm_lookup() as part of the
recent patch made it unclear if the release that was still there in
xfrm_lookup() was still needed or an oversight.
