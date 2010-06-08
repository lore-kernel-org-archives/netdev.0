From: Tim Gardner <tim.gardner@canonical.com>
Subject: 2.6.35-rc2, CONFIG_RPS is filling the dmesg log
Date: Tue, 08 Jun 2010 14:55:26 -0600
Message-ID: <4C0EAE3E.4070708@canonical.com>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:2020 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094Ab0FHV0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 17:26:36 -0400
Received: from [10.0.2.5] (unknown [10.0.2.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by mail.tpi.com (Postfix) with ESMTP id 4056723D6D8
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 13:54:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With 2.6.35-rc2 my dmesg log is being flooded with messages like this:

br0 received packet on queue 4, but number of RX queues is 1

This machine is bridged for KVM and has 2 igb network adapters.

The root cause appears to be CONFIG_RPS=y and the fact that none of the 
drivers that call skb_record_rx_queue() perform their net device 
allocation using alloc_netdev_mq(), thereby initializing num_rx_queues 
to a maximum of 1.

Given that this is early RPS days, is the warning in get_rps_cpu() 
really necessary? It would appear that _all_ of the multi-receive queue 
devices that call skb_record_rx_queue() will cause this log noise.

By the way, how do you turn off CONFIG_RPS? The only way I could get it 
disabled was to change the default in net/Kconfig to 'n'.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
