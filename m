From: Ben Greear <greearb@candelatech.com>
Subject: Ideas on why using WPA2 encryption speeds up many TCP connections?
Date: Thu, 03 Oct 2013 11:27:02 -0700
Message-ID: <524DB6F6.6020405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53959 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab3JCS1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 14:27:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing something a bit strange and wondering if anyone had an opinion on why...

I am testing up to 200 wifi station systems, each with a TCP connection running
on them (download only, from VAP to stations).

Without encryption (ie, open network), I see total throughput go from
about 108Mbps down to 69Mbps as I add more stations (I add 25 at a time,
so the 108Mbps is with 25 active, and 69Mbps is with 200 active).

However, if I enable encryption, the throughput is actually higher
(111Mbps to 71Mbps).  I'm doing encryption in software, so it adds a fair
bit of CPU load in this test.  The numbers bounce around since this is
wifi after all, but in general encryption tends to win reliably in this
test.

When testing with a single station (and 5 tcp streams with jacked up snd/rcv buffers)
the open networks perform significantly better at total throughput:  263Mbps vs 246Mbps.

Maybe the extra delay for decryption increases odds that GRO will take
affect for the many, slower streams (and maybe that will decrease ACK traffic?)

Any other ideas?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
