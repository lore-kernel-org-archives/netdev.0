From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 09:48:12 -0700
Message-ID: <OFD5BE4667.E4A6D7D5-ON88257303.005932BE-88257303.005C40E3@us.ibm.com>
References: <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cananian@gmail.com, netdev@vger.kernel.org,
	"=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=" <rdenis@simphalempin.com>
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:59790 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760275AbXFWQsS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 12:48:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5NGmHRC020809
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 12:48:17 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5NGmHYJ262434
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 10:48:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5NGmHlH023946
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 10:48:17 -0600
In-Reply-To: <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cananian@gmail.com wrote on 06/23/2007 07:47:06 AM:

> R=E9mi and Simon give my responses very eloquently.  Although you cou=
ld
> have yet-another-network-daemon redundantly process RA messages, the
> kernel is doing it already and it makes sense to just push this

        It would be two pieces looking at the same packet, but it isn't
redundant processing. The kernel would ignore the RDNS header, and the
app would ignore everything else; everything would be processed once.

> Although parsing
> RA messages and processing expiry in userland looks barely-possible
> now,
        "barely possible"?? See below.

> SeND support is really necessary for long-term IPv6 security, and
> duplicating SeND functionality in userland would be a nightmare.
> Futher, the neighbor discover protocol involves Router Solicitation
> messages which elicit the Router Advertisement reply, and we really
> don't want userland sending redundant Router Solicitation messages
> around, just because the kernel doesn't want to tell it what Router
> Advertisements it received.  I considered storing the *complete*
> Router Advertisement messages received and pushing them unparsed to
> userland, just to get around the bogus "DNS in the kernel" politics
> (hint: it's not a resolver in the kernel, it's just nameserver
> addresses being stored).  Does anyone really suggest that this would
> be a better solution?

        No, in fact! I didn't hear anyone suggesting that all of
neighbor discovery be pushed out of the kernel. All I suggested is
that you read a raw ICMPv6 socket for RA's that have the RDNS header
and the app _process_the_RDNS_header. The kernel should still continue
to do everything it needs to with the kernel data in the RA. Then you
just need a hash table (or maybe just a list -- there shouldn't be a
lot of them) and a timer to delete them when the RDNS expiration hits.
Easy, right?
        You might have to change the icmp6_filter, if RA's are not
already copied to raw sockets (I don't know either way offhand),
but that's a trivial kernel patch; otherwise, I don't believe you
have to do anything but read the socket and process the RDNS header
on RAs you receive.
=20
 +-DLS

