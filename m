From: Chris Friesen <chris.friesen@genband.com>
Subject: anyone know of a bug which causes dev->qdisc to be noop_qdisc for
 a working interface?
Date: Thu, 26 Jul 2012 17:30:39 -0600
Message-ID: <5011D31F.4060001@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:59106 "EHLO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab2GZXaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 19:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I've been asked to help debug an issue we've had in the field where 
after a month or so of uptime for a server the router it was connected 
to was rebooted and one of the eth links stopped transmitting packets. 
Downing and upping the link doesn't fix it.  An ethtool offline selftest 
doesn't fix it.  Only known fix is a reboot of the server.

The server is running 2.6.14, which makes things interesting.

Luckily we had kprobes enabled and I tracked down the source code, and 
I've been able to isolate the source of the problem.  It seems that for 
the problematic eth device (which is up and is receiving packets) 
dev->qdisc is set to noop_qdisc, which ends up silently dropping all 
outgoing packets on the floor.  dev->qdisc_sleeping is pfifo_fast as 
expected.

Does anyone have any ideas how this might have happened?  Does anyone 
remember a bug in this area from that long ago?

Thanks,
Chris

-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
