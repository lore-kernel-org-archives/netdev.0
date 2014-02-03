From: "Vic" <kernel@beer.org.uk>
Subject: Bug in IPv4 version of ping...
Date: Mon, 3 Feb 2014 10:31:47 -0000 (GMT)
Message-ID: <18429.78.154.109.125.1391423507.squirrel@yellowside.org.uk>
Reply-To: kernel@beer.org.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beer.org.uk ([91.84.48.107]:37910 "EHLO hobgoblin.beer.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbaBCLb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Feb 2014 06:31:59 -0500
Received: from hobgoblin.beer.org.uk (hobgoblin [127.0.0.1] (may be forged))
	by hobgoblin.beer.org.uk (8.13.1/8.13.1) with ESMTP id s13AVpkT017486
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 10:31:51 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi All.

I hope this is the right place to post this - this list is mentioned as
the mailing list for iputils.

I believe I've found a bug in ping.c - there is an ancient work-around for
an IP_RECVERR bug in raw sockets. The problem is as follows :-

ping_common.c defines a variable working_recverr
ping.c uses this variable to work out what it should do under certain
failure circumstances.

As far as I can see, working_recverr is undefined when first used; the
initial response to it could be either way. This leads to an erroneous
report that the kernel is "not very fresh", and needs to be upgraded.

I have seen this in the current builds for RHEL5 and 6 (s20071127) and in
the current release (s20121221).

I suspect this variable should be set somewhere after option parsing...

HTH

Vic.
