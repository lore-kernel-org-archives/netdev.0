From: Scott Harrison <scoharr2@cisco.com>
Subject: ixgbe driver fails occasionally since
 ee98b577e7711d5890ded2c7b05578a29512bd39
Date: Thu, 23 Oct 2014 15:06:25 +0100
Message-ID: <20141023140625.GD1480@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aer-iport-2.cisco.com ([173.38.203.52]:61816 "EHLO
	aer-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbaJWOQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 10:16:24 -0400
Received: from ukdev-build-sha.rusclabs.cisco.com ([10.50.153.119])
	by aer-core-3.cisco.com (8.14.5/8.14.5) with ESMTP id s9NE6PjX024874
	for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 14:06:25 GMT
Received: from cisco.com (localhost [127.0.0.1])
	by ukdev-build-sha.rusclabs.cisco.com (Postfix) with SMTP id C088F6ED0E6D
	for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 15:06:25 +0100 (BST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was asked to raise this issue here.

https://bugzilla.kernel.org/show_bug.cgi?id=86591

lspci ->

03:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
03:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)

With the fibre 10Gbs SFP occasionally on reboot we get

[   15.104726] ixgbe 0000:03:00.0 eth0: detected SFP+: 5                        
[   19.735155] ixgbe 0000:03:00.0 eth0: setup link failed with code -14  

Probably about 1 in 10 boots.  With the 1Gbs Copper SFP it works fine.  
kernel 3.14.8 worked fine, but on upgrading to 3.16.1 it fails in this way.  
I have narrowed it down to the commit

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=ee98b577e7711d5890ded2c7b05578a29512bd39

I don't know enough about the hardware to understand why the change 
sometimes causes the failure, and was hoping someone else would.  Reverting 
this commit on 3.16.1 fixes the issue.

If you need any more information please ask.

Scott.

-- 
Software Engineer

Cisco.com - http://www.cisco.com

This email may contain confidential and privileged material for the sole use of 
the intended recipient. Any review, use, distribution or disclosure by others 
is strictly prohibited. If you are not the intended recipient (or authorised to 
receive for the recipient), please contact the sender by reply email and delete 
all copies of this message.

For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
