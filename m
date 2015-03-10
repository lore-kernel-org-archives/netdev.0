From: David Miller <davem@davemloft.net>
Subject: rtnl_newlink() cleanup on namespace change
Date: Tue, 10 Mar 2015 18:43:47 -0400 (EDT)
Message-ID: <20150310.184347.1581730121744725414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbbCJWnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cong, I was reviewing commit 7afb8886a05be68e376655539a064ec672de8a8e
("rtnetlink: call ->dellink on failure when ->newlink exists") during
a stable backport and I noticed that the function, after the change
you made, subsequently goes:

		if (link_net) {
			err = dev_change_net_namespace(dev, dest_net, ifname);
			if (err < 0)
				unregister_netdevice(dev);
		}

Isn't the potential ->dellink() unwinding necessary in this path too?

If not, why not?

Thanks.
