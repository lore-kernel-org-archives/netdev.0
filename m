From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [BUG] net: cpu offline cause napi stall
Date: Wed, 1 Jun 2011 12:33:56 +0200
Message-ID: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	heiko.carstens@de.ibm.com
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:50684 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933372Ab1FAKeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 06:34:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Eric,

during heavy network load we turn off/on cpus.
Sometimes this causes a stall on the network device.
Digging into the dump I found out following:

napi is scheduled but does not run. From the I/O buffers
and the napi state I see napi/rx_softirq processing has stopped
because the budget was reached. napi stays in the
softnet_data poll_list and the rx_softirq was raised again.

I assume at this time the cpu offline comes in.
the rx softirq is raised/moved to another cpu but napi stays in the poll_list
of the softnet_data of the now offline cpu.

reviewing dev_cpu_callback (net/core/dev.c) I did not find the poll_list
is transfered to the new cpu. Do you think this could cause the stall or
did I miss something?

Thx for your help.

Frank

