From: "Deep Datta" <ddatta@ixiacom.com>
Subject: is it proper to do sk->sk_prot->unhash(sk) on a socket from a kernel module?
Date: Tue, 3 Mar 2009 02:09:33 -0800
Message-ID: <4C3C777A1128A74BA27FECF4E421BCBE0503F13D@IXCA-EXCHANGE.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixqw-mail-out.ixiacom.com ([66.77.12.12]:4152 "EHLO
	IXCA-EXCHANGE.ixiacom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750734AbZCCKYo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 05:24:44 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to have a set of send-only UDP sockets in my kernel module (The
receives will all be handled by a single socket bound to port n &
INADDR_ANY). 

So I did a bind(), connect()and sk->sk_prot->unhash(sk) on the sockets 
such that udp_rcv()/udpv6_rcv() will not find these socket when it does
a udp_vx_lookup(), instead pushing all the packets into the single
receive socket.
These unhashed sockets are only used to do udp_sendpage().

My questions are:
Are there any issues with this approach? 
Can this design break with changes in future kernel?
Are there any other proper ways to have a send-only UDP socket?

Thanks in advance,
Deep

