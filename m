From: Bruce Cran <bruce@cran.org.uk>
Subject: connect() sometimes succeeds when it shouldn't
Date: Thu, 18 Feb 2010 19:47:10 +0000
Message-ID: <201002181947.11125.bruce@cran.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from muon.cran.org.uk ([109.74.192.160]:39169 "EHLO muon.cran.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341Ab0BRT4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 14:56:02 -0500
Received: from muon.cran.org.uk (localhost [127.0.0.1])
	by muon.cran.org.uk (Postfix) with ESMTP id A50058E3E
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 19:46:47 +0000 (UTC)
Received: from tau.cran.uk.to (client-82-26-123-134.midd.adsl.virginmedia.com [82.26.123.134])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by muon.cran.org.uk (Postfix) with ESMTPSA
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 19:46:47 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I've found that if I run a program that does lots of calls to connect() then 
it will eventually succeed when there's no server listening. For SCTP it takes 
a few thousand, for TCP up to a couple of million.  I first came across the 
problem in Windows, where the connection was being processed so quickly that 
by the time the handler function had finished, the 'connecting' flag had 
already been reset, which wasn't expected. I've not checked the Linux sources 
to see if something similar is happening though.

The machine I tested it on was running a 2.6.32 i686 kernel.

The test code can be found at 
http://www.cran.org.uk/~brucec/linux/badconnect.c

-- 
Bruce Cran
