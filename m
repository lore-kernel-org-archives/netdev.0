From: Christian Kujau <lists@nerdbynature.de>
Subject: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Sun, 2 Sep 2007 15:11:29 +0200 (CEST)
Message-ID: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:41812 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965132AbXIBNLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 09:11:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after upgrading to 2.6.23-rc5 (and applying davem's fix [0]), lockdep 
was quite noisy when I tried to shape my external (wireless) interface:

[ 6400.534545] FahCore_78.exe/3552 just changed the state of lock:
[ 6400.534713]  (&dev->ingress_lock){-+..}, at: [<c038d595>] netif_receive_skb+0x2d5/0x3c0
[ 6400.534941] but this lock took another, soft-read-irq-unsafe lock in the past:
[ 6400.535145]  (police_lock){-.--}

This happened when I executed: http://nerdbynature.de/bits/2.6.23-rc5/qos.sh.txt
(using iproute2-ss070313). The is still running, I just noticed a short 
hickup, probably when it was busy writing the warning to the disk.

More details and .config: http://nerdbynature.de/bits/2.6.23-rc5/

I'm not really sure what the application mentioned in the message above 
has to do with this: the application[1] has been running since bootup as 
a non-privileged user and did so for earlier kernel versions too.

Christian.

[0] http://lkml.org/lkml/2007/9/2/6
[1] http://folding.stanford.edu/linux.html
-- 
BOFH excuse #294:

PCMCIA slave driver
