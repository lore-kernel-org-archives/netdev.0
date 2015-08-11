From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: Question on behavior of tg3_self_test() (ethtool -t on tg3 driver)
Date: Tue, 11 Aug 2015 10:59:45 -0500
Message-ID: <55CA1BF1.2060403@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e19.ny.us.ibm.com ([129.33.205.209]:33727 "EHLO
	e19.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211AbbHKP7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 11:59:50 -0400
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Tue, 11 Aug 2015 11:59:49 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2177D38C804F
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 11:59:47 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7BFxlnB51511432
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 15:59:47 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7BFxkYA010957
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 11:59:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry if you got several duplicates, am trying to work through rejected 
messages due to supposed HTML content)

The following behavior is being observed when running "ethtool -t <dev> 
offline" on ports on the Broadcom BCM5719 adapter (tg3 driver). The 
ports have wrap plugs on them, although I'm not sure why that would have 
any affect.

The test "ethtool -t <dev> offline" was being running continuously. The 
first invocation passes, all subsequent ones fail (at least in the "link 
test" step) after ~20 second timeout. When running the test once, I see 
the following: Looking at /var/log/messages, I see a "Link is down" 
message during the test. Then, 20 seconds after the test completes, 
there is a "Link is up..." message. If I wait for the "Link is up..." 
message I can run the test without problems. If the test is run again 
while the link is still down, it fails and seems to delay the "link up" 
by an additional 20 seconds.

If I run "external_lb" instead of "offline", I am able to run the test 
repeatedly without error. So it seems that some action taken in the 
"external_lb" case actually "repairs" the port. But the "external_lb" 
test also exhibits the link-down for 20 seconds symptom, although it can 
been run while the link is considered "down" without failure.

The first question is whether we should expect to be able to run 
"ethtool -t <dev> offline" continually, with no delay between runs. I 
presume this is supported.

Second question, I would like someone with experience with the tg3 
driver and this adapter to comment on what might be done to fix this. My 
first, simple, guess would be move the "tg3_phy_lpbk_set(tp, 0, true);" 
setting (in tg3_test_loopback()) to be done for both "offline" and 
"external_lb" cases. I am awaiting time on a system with this adapter in 
order to try out some possible fixes and/or debug what might be 
wrong/different with the configuration after the "offline" test.

I would appreciate any help,
Thanks,
Doug Miller
