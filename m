From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: neigh_periodic_timer expires too often
Date: Thu, 30 Jul 2009 13:44:21 +0300
Message-ID: <4A717985.7060909@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tero.kristo@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:24165 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbZG3Kob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 06:44:31 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6UAha0H000317
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 05:44:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We were making some measurements and trying to figure out which timers 
in the kernel can be made deferrable so that our device doesn't have to 
wake up too often.

During this investigation, we found out that the neigh_periodic_timer is 
expiring approximately every 8 seconds, even when we don't have a 
network connection established.  After the connection is established, 
the timer starts expiring every 2 seconds and continues to expire at 
this interval after the connection is closed.

We have been converting many of the kernel times to deferrable timers.  
Checking the netdev mailing list archives, I found out that this issue 
has been discussed in December 2007 [1], but the thread seems to have 
died out and the proposed patch has never been applied AFAICS.

Another proposed solution, which has never been applied either, was to 
convert this timer from softirq-based to workqueue-based [2].  Would 
that be any better?

So, my question is, does it make sense to make this timer deferrable or 
use the workqueue instead? Or is there any other better solution to 
avoid unnecessarily frequent wakeups caused by neigh_periodic_timer?

We are using a kernel based on 2.6.28.

[1] http://article.gmane.org/gmane.linux.network/81361
[2] http://article.gmane.org/gmane.linux.network/81140

-- 
Cheers,
Luca.

