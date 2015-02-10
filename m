From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Kernel sends ICMP unreachable for GRE packets even if there is a
 listening socket
Date: Tue, 10 Feb 2015 16:24:10 +0100
Message-ID: <20150210152410.GA9225@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:39352 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbbBJPYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 10:24:16 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1YLCfb-000267-1v
	for netdev@vger.kernel.org; Tue, 10 Feb 2015 16:24:11 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1YLCfa-0003k8-R1
	for netdev@vger.kernel.org; Tue, 10 Feb 2015 16:24:10 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resent from Bugzilla]

Hi,

I have a userspace GRE listener, which opens a raw socket (error handling removed):

        int gresock = socket(AF_INET6, SOCK_RAW, IPPROTO_GRE);
        bind(gresock, (sockaddr *)&my_addr, sizeof(my_addr));

and then select()s and recvfrom()s on it, as well as sendto().

This works great. I can send and receive GRE packets. However, Linux _also_
sends ICMPv6 unreachables when the other end sends to me. I assume this is
because I don't have a corresponding kernel GRE tunnel interface. (I don't use
the kernel GRE because I want, among others, stronger reordering functionality
and possibly error correction, which is not in any standard.)

Can this be suppressed when I have such a socket giong? ip6tables -A OUTPUT can
stop them, but it seems very hacky and kludgy.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
