From: Jiri Pirko <jpirko@redhat.com>
Subject: octeon dev_addrs list usage
Date: Tue, 23 Feb 2010 21:41:52 +0100
Message-ID: <20100223204151.GG2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411Ab0BWUlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 15:41:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David.

Lookin at octeon driver, drivers/net/octeon/octeon_mgmt.c,
octeon_mgmt_set_rx_filtering function and following code:

503         if (cam_mode == 1) {
504                 /* Add primary address. */
505                 octeon_mgmt_cam_state_add(&cam_state, netdev->dev_addr);
506                 list_for_each(pos, &netdev->dev_addrs.list) {
507                         struct netdev_hw_addr *hw_addr;
508                         hw_addr = list_entry(pos, struct netdev_hw_addr, list);
509                         octeon_mgmt_cam_state_add(&cam_state, hw_addr->addr);
510                         list = list->next;
511                 }
512         }

besides netdev->dev_addr is first entry in netdev->dev_addrs.list and
"list = list->next;" makes no sense here (I posted a patch correcting
these earlier), are you sure you are traversing the right list? This list is
currently not filled in anywhere (besides ixgbe driver). Don't you want
to traverse through unicast_list instead? Maybe I'm missing something...

Thanks.

Jirka
