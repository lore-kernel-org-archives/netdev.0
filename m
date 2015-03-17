From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: iproute2: ip -force -batch does not continue on errors
Date: Tue, 17 Mar 2015 16:07:08 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1503171550360.18888@aurora64.sdinet.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blackhole.sdinet.de ([176.9.52.58]:53631 "EHLO mail.sdinet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908AbbCQPOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 11:14:04 -0400
Received: from aurora64.sdinet.de (aurora64.sdinet.de [193.103.159.64])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: haegar)
	by mail.sdinet.de (bofa-smtpd) with ESMTPSA id 78FE12E80513
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 16:07:15 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo,

Test szenario:

# cat b.txt
route del 1.2.3.0/24 dev eth0
route del 1.2.4.0/24 dev eth0
route del 1.2.5.0/24 dev eth0
route add 1.2.3.0/24 dev eth0

# ip -force -batch b.txt
RTNETLINK answers: No such process

Expectation: The three route del commands may fail if the route does 
not (yet) exist, and then (as I am using -force) the route add gets 
executed.

But instead the batch processing is aborted at the first failing "route 
del" command, forcing me to execute ip once per route del instead of 
using the batchmode.

Tested mainly using iproute2 3.16.0, but the current git tree seems to 
behave mostly the same, except that it only executes anything if I add 
"-f inet" to the commandline, otherwise it rejects the first line with 
'Error: an inet prefix is expected rather than "1.2.3.0/24".'

c'ya
sven-haegar

-- 
Three may keep a secret, if two of them are dead.
- Ben F.
