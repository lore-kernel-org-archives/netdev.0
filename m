From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 06:20:29 -0700
Message-ID: <OF0DBC22C3.C87A2D77-ON88257315.0046DAAD-88257315.00493963@us.ibm.com>
References: <200707111544.43151.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46551 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375AbXGKNUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 09:20:37 -0400
In-Reply-To: <200707111544.43151.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think #2 in your list is the right choice, and that has nothing to do 
with adding a
non-standard option (which I completely agree is a bad idea).

It looked like you're just checking if the machine is acting as a router 
or not and
if it comes from a link-local address; is that right? Of course, lots of 
apps already
check for "am I a router" and they don't require a new socket option. (!) 
See everything
in the quagga package, for example. And checking the address type in a app 
is
trivial.

The previous discussion about "validation" was talking about RA's that are 
forged,
so don't pass IPsec authentication checks. I don't see any reason at all 
to deliver those
to an application (ever), so no non-standard socket option required there. 
I don't know
if those are currently delivered on raw sockets or not, but if they are, I 
think it's
reasonable to have a patch that clones them only after authentication 
rather than before.

Prior discussion used FUD about some monitoring apps needing to see forged 
RA's.
I don't think there really are apps that need to see forged RA's, but if 
they really
want everything, they should use bpf or the like, just as they would need 
to do to
receive, for example, packets with invalid checksums.

                                                                +-DLS

