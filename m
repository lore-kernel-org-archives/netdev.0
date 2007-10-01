From: Ben Greear <greearb@candelatech.com>
Subject: How do queue-less virtual devices wake higher level senders?
Date: Mon, 01 Oct 2007 16:49:06 -0700
Message-ID: <47018772.4060803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40539 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbXJAXtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 19:49:08 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l91Nn6iP028824
	for <netdev@vger.kernel.org>; Mon, 1 Oct 2007 16:49:07 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I am having some trouble figuring out how virtual interfaces
(such as mac-vlans) can wake up writers (such as udp sockets).

For 'real' hardware, it seems that the netif_stop_queue and
netif_wake_queue methods handle stopping and waking the
higher level senders, but for virtual devices with no
queues, how does this work?

In my case, I'm using a virtual Station interface that sits on
top of a wifi radio interface (hacked up madwifi).  I notice
that UDP connections set up for high speed, unidirectional
sends are stalling after a few minutes.  netstat -an shows
a write-buffer that is quite full, but nothing is transmitted.

If I ping or start any other type of traffic on these interfaces,
the udp recovers.  It seems like the udp send logic is just
getting stuck and needs a kick.

I do not see any problems with TCP connections, and if I keep
a slow-speed tcp connection running, the UDP will not hang.

It's likely the bug is in my driver and/or code, so this is
not a bug report..just a question to hopefully help me debug
it further :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

