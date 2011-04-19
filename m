From: Tim Gardner <tim.gardner@canonical.com>
Subject: 2.6.38 dev_watchdog WARNING
Date: Tue, 19 Apr 2011 11:40:02 -0600
Message-ID: <4DADC8F2.9050700@canonical.com>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:2691 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121Ab1DSSHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 14:07:34 -0400
Received: from [10.0.2.5] (unknown [10.0.2.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by mail.tpi.com (Postfix) with ESMTP id C08CA201C9B
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 10:39:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing a lot of these kinds of bugs: WARNING: at 
/build/buildd/linux-2.6.38/net/sched/sch_generic.c:256 
dev_watchdog+0x213/0x220()

The kernel is 2.6.38.2 plus Ubuntu cruft.

A spot check of the 200+ hits on this string indicates they are 
primarily due to these drivers:

ipheth
atl1c
sis900
r8169

As far as I can tell the warning happens when link is down on the media 
(and has never been link UP) and are sent a transmit packet which never 
completes. Is there a net/core or net/sched requirement to which these 
drivers do not conform ? Are they not correctly indicating link status?

rtg
-- 
Tim Gardner tim.gardner@canonical.com
