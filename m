From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Thu, 01 Mar 2012 22:23:16 -0500 (EST)
Message-ID: <20120301.222316.1877216960521396397.davem@davemloft.net>
References: <20120302025554.GA13493@joana>
	<20120301.221643.881299898523907213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johan.hedberg@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: gustavo@padovan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab2CBDYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 22:24:33 -0500
In-Reply-To: <20120301.221643.881299898523907213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 01 Mar 2012 22:16:43 -0500 (EST)

> This was only three commits into your tree, therefore I'm not very
> optimistic to be honest with you.

In the very next commit, 3175405b906a85ed2bad21e09c444266e4a05a8e we end
up with:

		mgmt_device_found(hdev, &info->bdaddr, ACL_LINK, 0x00,
					info->dev_class, 0, 1, NULL);

which after all the rest of the commits still looks like:

		mgmt_device_found(hdev, &info->bdaddr, ACL_LINK, 0x00,
					info->dev_class, 0, !name_known, ssp,
					NULL, 0);

You have to make those arguments line up properly:

		mgmt_device_found(hdev, &info->bdaddr, ACL_LINK, 0x00,
				  info->dev_class, 0, !name_known, ssp,
				  NULL, 0);
