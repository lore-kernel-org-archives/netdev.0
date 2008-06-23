From: "Chris Friesen" <cfriesen@nortel.com>
Subject: looking for explanation of select() timeout behaviour
Date: Mon, 23 Jun 2008 10:00:26 -0600
Message-ID: <485FC89A.30309@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:38518 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbYFWQAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 12:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got something odd in a recent strace log (running on an older 
kernel, I haven't yet tried to reproduce in mainline):

20418 22:06:50.583303 select(19, [7 11 12 13 14 15 16 17 18], NULL, 
NULL, {0, 498508}) = 1 (in [11], left {0, 0}) <5.074137>

select() was called with a timeout of half a second.  Five seconds later 
it returns with zero time left and a single socket readable.  Why 
wouldn't it have returned after half a second with a timeout?

My immediate suspicion would be to look at scheduler behaviour, but are 
there any other explanations?  I'm fairly sure system time wasn't 
changed during this interval (the system should have been ntp-synced).

Thanks,

Chris
