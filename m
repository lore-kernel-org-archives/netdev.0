From: Thomas Martitz <kugel@rockbox.org>
Subject: Bridge IGMP snooping question
Date: Fri, 19 Sep 2014 20:55:31 +0200
Message-ID: <541C7C23.90008@rockbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.t-online.de ([194.25.134.80]:42850 "EHLO
	mailout01.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757658AbaISTCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 15:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Linux folks,

I have one question regarding IGMP snooping on bridges, specifically 
about leaving multicast groups.

br_multicast_leave_group() has this check early on:

if (!netif_running(br->dev) ||
         (port && port->state == BR_STATE_DISABLED) ||
         timer_pending(&querier->timer)) /* <- THIS */
                goto out;

I'm wondering why the bridge code prevents group leaves if if the 
querier timer is pending. From my understanding the timer acts as an 
indication whether the local system is the network's querier or not (if 
pending then another router is querier). Therefore this check prevents 
to leave groups if there is another querier.

I'm wondering what's the rationale for this, if any. It seems to be that 
the decision whether an attached client gets mc forwarded is independent 
on whether the local system is querier or not. Git log does not reveal 
the answer as this check is there from the beginning.

PS: This behavior conflicts with something I'm working.

Thank you very much in advance.

Best regards.
