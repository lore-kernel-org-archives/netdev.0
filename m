From: Jeff Garzik <jeff@garzik.org>
Subject: d80211: bitfield usage should go
Date: Wed, 09 Aug 2006 05:07:41 -0400
Message-ID: <44D9A5DD.8080103@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40871 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030586AbWHIJHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:07:43 -0400
Received: from cpe-065-190-194-075.nc.res.rr.com ([65.190.194.75] helo=[10.10.10.99])
	by mail.dvmed.net with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1GAk2Q-0004TM-6e
	for netdev@vger.kernel.org; Wed, 09 Aug 2006 09:07:42 +0000
To: Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm doing an in-depth review of d80211 right now.

One issue that leaps out:  use of bitfields.

1) single-bit signed bitfields are undefined

	int wep_include_iv:1;

2) bitfields in general generate HORRIBLE code.  Just don't use them. 
Compilers often fail to use even the most obvious simplifications.

Use flags and bitwise operators instead, like most other Linux code.

