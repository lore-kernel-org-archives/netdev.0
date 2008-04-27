From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Update MTU to all related cache entries in
 ip_rt_frag_needed()
Date: Sat, 26 Apr 2008 23:27:56 -0700 (PDT)
Message-ID: <20080426.232756.259679168.davem@davemloft.net>
References: <48105B67.7060804@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbYD0G17 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 02:27:59 -0400
In-Reply-To: <48105B67.7060804@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 24 Apr 2008 13:05:27 +0300

> Add struct net_device parameter to ip_rt_frag_needed() and update MTU=
 to
> cache entries where ifindex is specified. This is similar to what is
> already done in ip_rt_redirect().
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> ---
> I noticed this bug when using GRE tunnel bound to specific device. Th=
is
> causes ip_gre to use ifindex in ip_route_output_key() lookups and the
> results are not proper unless the MTU is updated for entries where
> ifindex is specified (causing my tunneled packets to be dropped).
>=20
> I have a patch for older kernels too if this is good for -stable.

I haven't forgotten about this patch, I'm just still thinking about
possible negative side effects.  I don't think there are any, but
I want to be sure.

This function has been a constant source of consternation.  It also
doesn't do the right thing when the TOS is modified mid-network, and
that's arguably wrong too but more difficult to solve efficiently than
this ifindex keying case.
