From: Octavian Purdila <opurdila@ixiacom.com>
Subject: TSecr != 0 check in inet_lro.c
Date: Tue, 25 Aug 2009 00:54:50 +0300
Message-ID: <200908250054.50664.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>
To: "Jan-Bernd Themann" <themann@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12081 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753082AbZHXV5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 17:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

We are seeing a performance issue with TSO/LRO which we tracked down to the 
TSecr !=0 check in lro_tcp_ip_check.

It happens when the LRO side's TSval wraps around and gets to 0. That triggers 
the TSO side to send packets with TSecr set to 0, which means that such 
packets won't be aggregated - and that will put a lot of burden on the stack 
which will result in lots of drops.

I'm failing to understand the purpose of this check. Any hints? :)

Thanks,
tavi
