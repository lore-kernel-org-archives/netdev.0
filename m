From: Toerless Eckert <Toerless.Eckert@Informatik.Uni-Erlangen.de>
Subject: Re: netdev: fwmarks questions
Date: Thu, 10 Nov 2011 20:22:53 +0100
Message-ID: <20111110192253.GL14734@faui40p.informatik.uni-erlangen.de>
References: <20111110191255.GK14734@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toerless Eckert <Toerless.Eckert@Informatik.Uni-Erlangen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:44912 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730Ab1KJTWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 14:22:55 -0500
Content-Disposition: inline
In-Reply-To: <20111110191255.GK14734@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typo in config below fixed

[ Sorry if this is the wron mailing list. Please let me know if so, and
  recommend a better list for these questions]

a) What APIs exist to set fwmarks for sockets. SO far i could only find:
   setsockopt(,SO_MARK,). But is there for example any system call to
   set the fwmark for all sockets of a process - and which is inherited
   across forks ? If not that, then anything else ?

b) Assume i have two physical ethernet interfaces,
   eth0 ip-address 10.1.1.1/24
   eth1 ip-address 10.10.10.1/24

   I do create a new routing table foobar. I populate it only with routes
   for eth1 (eg: interface route and maybe default route).

   ip route add 10.10.10.0/24 eth1 src 10.10.10.1  table foobar
   ip route add default via 10.10.10.254           table foobar

   I do map this routing table to some fwmark 1234 via eg:

   ip rule add fwmark 1234 table foobar

   Now i have an app with a socket like this:

     s = socket( ...ipv4...)
     setsockopt(s, ... SO_MARK, 1234)
     listen(s, 10)
   
   Question: Would s also accept incoming connections that came in over
   eth0, eg: to eth0, 10.1.1.1 ?

   Logically i think the socket should not accept such connections, but
   only those to eth1, or whatever else i have in my routing table foobar,
   but i have found no documentation that explains how listen() actually
   works when you use fwmarks.

Cheers
    Toerless
