From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] [IPV4]: Fix compatibility issue with ipv4_devconf_dflt
Date: Sat, 2 Jun 2007 20:01:32 +1000
Message-ID: <20070602100132.GA9129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4451 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbXFBKBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 06:01:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

When we moved the IPv4/IPv6 device creation from address addition time
to device registration time it changed the behaviour of the default
configuration values (e.g., /proc/sys/net/ipv4/conf/default).  Previously
you could specify default configuration values and as long as you do it
before any addresses are added (or when the device is brought up for IPv6)
it would apply to every single device other than loopback.

With the new scheme this no longer works for devices registered at boot
time (e.g., devices built-in to the kernel).  One such scenario can be
seen at http://bugzilla.kernel.org/show_bug.cgi?id=8519.

Since this is a kernel/user-space interface it'd be nice if we can keep
the compatibility while still achieving what we wanted.

The following series tries to do that for IPv4 by keeping track of what
the user has explicitly set and copying the default values over again
at the same points as before for values which have not been explicitly
set.

If this looks OK I'll do the same thing for IPv6 as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
