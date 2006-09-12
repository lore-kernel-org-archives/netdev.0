From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: A Networking Puzzle
Date: Tue, 12 Sep 2006 09:43:28 -0500
Message-ID: <4506C790.1020007@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:51945 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965155AbWILOne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 10:43:34 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I need help with a networking problem and I hope you can direct me to a guru.

As part of the changes in the bcm43xx driver just prior to 2.6.18, some sections 
that are executed periodically were made preemptible to reduce latency. For the 
most part, the effort was successful; however there are intermittent failures on 
certain systems. The code in question is run once per minute, with failures only 
after 6-10 hours when they occur. Fortunately for testing purposes, my system is 
one that is affected by this problem. In addition, I could tweak the code to run 
the problem section once per second. This way, I could experiment with the code 
and I think I found the problem.

In the code setting up the preemptive work, the relevant section has the following:

	...
	mutex_lock
	netif_stop_queue
	synchronize_net
	....

With this structure, a netdev watchdog tx timeout will happen every few hundred 
passes through the code, even if the timeout is set to 30 sec. From 
experimentation, I know that if the synchronize_net call is removed, or if it 
comes before the netif_stop_queue, I no longer get the errors. Of course it is 
possible that my changes just reduce the error rate to a level that I don't see 
it with limited testing. I'm hoping that an expert can explain which of these 
two changes might be correct, or what should be done.

Thanks,

Larry
