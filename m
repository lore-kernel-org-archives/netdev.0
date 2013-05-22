From: Ben Greear <greearb@candelatech.com>
Subject: question on pktgen shutdown logic.
Date: Wed, 22 May 2013 16:15:39 -0700
Message-ID: <519D519B.8040406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34425 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3EVXPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 19:15:40 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r4MNFdTL010976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 22 May 2013 16:15:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at pktgen.c in 3.9.3, I cannot explain how
it does not race on shutdown.

The thread worker checks for pktgen_exiting, and will bail out
of it's main loop and initiate cleanup if this is true.

The pg_net_exit sets the pktgen_exiting to true, and then
proceedes to call

		kthread_stop(t->tsk);
		kfree(t);

What I don't understand is what keeps the kfree(t) from happening
before the thread has noticed pktgen_exiting is set and properly
bailed out of it's loop and finished cleanup?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
