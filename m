From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ipv4: add hash-based multipath routing
Date: Mon, 13 Apr 2015 09:34:46 -0700
Message-ID: <20150413093446.438bca5e@urahara>
References: <20150412205430.6d7fcd30@tyr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32816 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbbDMQen convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 12:34:43 -0400
Received: by paboj16 with SMTP id oj16so107458835pab.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 09:34:43 -0700 (PDT)
In-Reply-To: <20150412205430.6d7fcd30@tyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Apr 2015 20:54:30 +0200
Peter N=C3=B8rlund <pch@ordbogen.com> wrote:

> Hi all,
>=20
> I'm working on adding L3/L4 hash-based IPv4 multipath to the kernel,
> but I wonder what the best approach for the mainline kernel is.
>=20
> When the IPv6 multipath code was added, choosing the routing algorith=
m
> by means of compile-time config or sysctl was rejected, so I assume
> that we want to revive the RTA_MP_ALGO or a new attribute?
>=20
> The IPv6 multipath uses L4 balancing - which is fine for IPv6 where
> fragmentation does not happend - but in my opinion the safest default
> for IPv4 is L3, especially when multipath is used together with anyca=
st.
>=20
> My main problem is the existing multipath code which is really old
> (linux 2.1.66). From the looks of it, it attempts to be somewhat rand=
om,
> but in reality it is more or less weighted round-robin, and as far as=
 I
> can tell it even has an off-by-one error in its handling of the rando=
m
> value. I think it is wise to support L3, L4, and per-packet
> load-balancing, just like the hardware vendors, but must the per-pack=
et
> load-balancing be default, or is it okay to change the default
> behavior? Also, would a weighted round-robin with a single per-cpu
> counter suffice? This would get rid of the spinlock and avoid causing
> cache invalidations of the route info with each packet. But it would =
not
> be true round-robin, which would require a per-route-info counter. If
> we are promising round-robin it is bad, but if we are simply promisin=
g
> weighted per-packet load-balancing, it's a different matter.

We (Brocade) did some work on this, but it never was done enough to
submit upstream. The ideal is to allow configuring choice of algorithm
per-route.
