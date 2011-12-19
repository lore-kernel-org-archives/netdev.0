From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Mon, 19 Dec 2011 14:52:59 +0100
Message-ID: <20111219135259.GK6348@secunet.com>
References: <4EE8C6A8.3060308@iki.fi>
 <20111214.125010.82857701285437834.davem@davemloft.net>
 <20111215134957.GI6348@secunet.com>
 <20111216122147.GJ6348@secunet.com>
 <4EEB5602.2060806@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58968 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997Ab1LSN5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 08:57:24 -0500
Content-Disposition: inline
In-Reply-To: <4EEB5602.2060806@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2011 at 04:30:26PM +0200, Timo Ter=E4s wrote:
> On 12/16/2011 02:21 PM, Steffen Klassert wrote:
> >=20
> > "ip route flush cache" does not even flush the routing cache,
> > it just markes the routing cache as invalid by changing the
> > rt_genid which make the old routes invisible. And since we don't
> > have rt_check_expire() anymore, we have to wait until we have
> > collected gc_thresh (1024) useless routes before rt_garbage_collect=
()
> > starts to remove some of them (btw. is this intentional).
> >=20
> > I think we need a trigger in rt_cache_invalidate() that expires
> > all cached pmtu values similar to the routing cache entries.
> > For a moment I thought we could just reset the __rt_peer_genid
> > value back to zero to mark all cached pmtu values as expired,
> > but that's apparently not save to do. So I came to no conclusion
> > how to fix this today. Any ideas?
>=20
> Oh, right. This problem is secondary. As long as the mtu value is
> reflected properly, I'll be happy :)
>=20

Well, "ip route flush cache" flushed the cached pmtu informations
in 2.6.38 and before, now it does not do it anymore. I guess
some users rely on the old behaviour, so it would be nice if we
could restore it. I think we can fix this by adding a pmtu_genid,
exactly in the same way as we have now the redirect_genid.
I'll give this a try.
