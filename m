From: subashab@codeaurora.org
Subject: [RFC] Handling device free after a packet is passed to the network
 stack
Date: Fri, 27 Mar 2015 19:57:34 -0000
Message-ID: <f3c7672edb978d520f12d72cb41d1e4d.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41158 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbbC0T5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 15:57:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been coming across a couple of scenarios where the device is freed
and the corresponding packets which were already queued up the stack
encounter crashes when they find that contents of skb->dev are no longer
valid.

Specifically, we have observed an instance where a cpu hotplug occurs
along with the network driver module unloading. When the packets are being
queued up the stack using netif_rx_ni from dev_cpu_callback, get_rps_cpus
crashes as it encounters invalid data at skb->dev since it would have been
freed.

We would like to know if the kernel provides some mechanisms to safeguard
against such scenarios.

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
