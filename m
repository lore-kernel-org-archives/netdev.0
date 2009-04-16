From: dmitry.krivoschekov@gmail.com
Subject: [PATCH 0/3]
Date: Thu, 16 Apr 2009 13:37:36 +0400
Message-ID: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:10137 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752437AbZDPJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:36:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series adds some flexibility to ip_auto_config() function.
Currently the function assumes that 500 msec delay before opening
a network device is enough, but it's not true for some h/w configurations,
e.g. if you're using a USB network device. 
In my case it may take up to 2 seconds before the device gets available 
for opening.

[PATCH 1/3] ipconfig: use same time units for CONF_{PRE,POST}_OPEN delays
	this is just a small cleanup

[PATCH 2/3] ipconfig: add 'ipwait' cmdline parameter
	I introduce a new cmdline parameter so it's possible to configure two 
	delays, before and after opening of network devices. It can be used 
	to increase default delay and it also might be useful in optimizing of
	kernel boot-up time, you can save ~1 second if you know that you h/w
	does not need that delays, 500 msec before and 1 second after.

[PATCH 3/3] ipconfig: look for a network device forever if NFS root
	As time needed for a USB net device to settle may vary from
	time to time, it's hard to predict how much msecs it would 
	take next time. If we're using such a device to mount a NFS root
	filesystem it gets critical for us as we can't proceed 
	work if a net device has not found, so we have to
	loop until a suitable device gets available.
	

Tested on TI OMAP3530 Beagle board.


Regards,
Dmitry

