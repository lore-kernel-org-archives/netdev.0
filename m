From: Ben Greear <greearb@candelatech.com>
Subject: pktgen and spin_lock_bh in xmit path
Date: Mon, 19 Oct 2009 20:38:03 -0700
Message-ID: <4ADD309B.1040505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33991 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbZJTDiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 23:38:01 -0400
Received: from [71.112.54.138] (pool-71-112-54-138.sttlwa.dsl-w.verizon.net [71.112.54.138])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n9K3c3t5025432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 20:38:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm having strange issues when running pktgen on 10G interfaces while 
also running
pktgen on mac-vlans on that interface, when the mac-vlan pktgen threads 
are on a different
CPU.

First, lockdep gives up and says that things are not properly 
annotated.  I believe this is because
the macvlan tx path will lock it's txq and will also lock the 
lower-dev's txq.  To fix this, perhaps
we need some new lockdep aware primitives for netdev txq locking?

Second, is using _bh() locking really sufficient if we have pktgen 
writing to a physical device
and also have other pktgen threads writing to that same device though 
mac-vlans?   I'm seeing
deadlocks spinning on the _bh() lock in pktgen as well as strange 
corruptions, so I think there
must be *some* problem somewhere, I just don't know quite what it is yet.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


