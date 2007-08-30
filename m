From: Francesco Dolcini <fdolcini@sysnetsistemi.it>
Subject: bonding xmit overwrite skb->priority
Date: Thu, 30 Aug 2007 12:06:20 +0200
Message-ID: <46D6969C.5080005@sysnetsistemi.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.libero.it ([212.52.84.43]:37468 "EHLO
	smtp-out3.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbXH3KGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 06:06:23 -0400
Received: from localhost (172.31.0.41) by smtp-out3.libero.it (7.3.120)
        id 4688F31B052CC420 for netdev@vger.kernel.org; Thu, 30 Aug 2007 12:06:21 +0200
Received: from smtp-out2.libero.it ([172.31.0.38])
	by localhost (asav-out1.libero.it [192.168.32.29]) (amavisd-new, port 10024)
	with ESMTP id owSW1YdRcCMW for <netdev@vger.kernel.org>;
	Thu, 30 Aug 2007 12:06:21 +0200 (CEST)
Received: from outrelay08.libero.it (192.168.32.103) by smtp-out2.libero.it (7.3.120)
        id 46A743AE01E29256 for netdev@vger.kernel.org; Thu, 30 Aug 2007 12:06:21 +0200
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by fd.sysnet.local (Postfix) with ESMTP id EC6C878162
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 12:06:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonding code set skb->priority=1 before trasmitting frame to the slave 
device (bond_dev_queue_xmit() in bond_main.c). The only reason I can 
think of doing this is to be sure that control packet used by bonding 
specific implementation (802.3ad PDU for example) using priority 
TC_PRIO_CONTROL will never get delayed by other traffic (using the 
default qdisc pfifo_fast). The problem doing this is that priority 
information in skb get lost.
I removed this line because I need to trust skb priority in the slave 
device qdisc and I got no negative effects, am I missing something? 
There are other reason for setting skb->priority to 1?

thanks

Francesco
