From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: MSI interrupts and disable_irq
Date: Thu, 27 Sep 2007 16:42:17 -0400
Message-ID: <46FC15A9.1070803@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:1371 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbXI1SCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:02:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am trying to track down a forcedeth driver issue described by bug 9047 
in bugzilla (2.6.23-rc7-git1 forcedeth w/ MCP55 oops under heavy load). 
I added a patch to synchronize the timer handlers so that one handler 
doesn't accidently enable the IRQ while another timer handler is running 
(see attachment 'Add timer lock' in bug report) and for other processing 
protection.

However, the system still had an Oops. So I added a lock around the 
nv_rx_process_optimized() and the Oops has not happened (see attachment 
'New patch for locking' in bug report). This would imply a 
synchronization issue. However, the only callers of that function are 
the IRQ handler and the timer handlers (in non-NAPI case). The timer 
handlers  use disable_irq so that the IRQ handler does not contend with 
them. It looks as if disable_irq is not working properly.

This issue repros only with MSI interrupt and not legacy INTx 
interrupts. Any ideas?

Thanks,
Ayaz
