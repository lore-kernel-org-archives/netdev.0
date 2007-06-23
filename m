From: "C. Scott Ananian" <cscott@laptop.org>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 10:47:06 -0400
Message-ID: <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
	 <200706231625.44825@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Stevens" <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=" <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:64593 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757117AbXFWOrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 10:47:08 -0400
Received: by ug-out-1314.google.com with SMTP id j3so998560ugf
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 07:47:06 -0700 (PDT)
In-Reply-To: <200706231625.44825@auguste.remlab.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi and Simon give my responses very eloquently.  Although you could
have yet-another-network-daemon redundantly process RA messages, the
kernel is doing it already and it makes sense to just push this
information to userland using /proc and/or netlink.  Although parsing
RA messages and processing expiry in userland looks barely-possible
now, SeND support is really necessary for long-term IPv6 security, and
duplicating SeND functionality in userland would be a nightmare.
=46uther, the neighbor discover protocol involves Router Solicitation
messages which elicit the Router Advertisement reply, and we really
don't want userland sending redundant Router Solicitation messages
around, just because the kernel doesn't want to tell it what Router
Advertisements it received.  I considered storing the *complete*
Router Advertisement messages received and pushing them unparsed to
userland, just to get around the bogus "DNS in the kernel" politics
(hint: it's not a resolver in the kernel, it's just nameserver
addresses being stored).  Does anyone really suggest that this would
be a better solution?

The goal is to push the userland component into glibc, likely through
a NSS resolver plugin.  Current glibc doesn't do any processing to
determine when /etc/resolv.conf has changed, which is a problem for
long-running applications.  Exporting RDNSS-in-RA via netlink messages
(or by poll() on a /proc file as is done for /proc/<pid>/mounts, which
was suggested in linux-kernel) is an elegant solution that (as R=E9mi
noted) cleanly handles interface up/down/reconfig, route expiration,
and (eventually) the cryptographic neighbor discovery protocol without
weaving a web of hairs from the kernel to the resolver.
 --scott

--=20
                         ( http://cscott.net/ )
