From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool
 support
Date: Tue, 26 Apr 2016 17:41:50 -0400 (EDT)
Message-ID: <20160426.174150.2239494413467110.davem@davemloft.net>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
	<20160426.160301.938979848864279754.davem@davemloft.net>
	<CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	talal@mellanox.com, eranbe@mellanox.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbcDZVlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:41:53 -0400
In-Reply-To: <CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Tue, 26 Apr 2016 23:55:03 +0300

> It will be a nightmare to rollback in such case.  What if the rollback failed ?

It is absolutely essential to handle this properly.

Which means you must have a prepare/commit model, wherein the prepare
phase makes sure to pre-allocate all necessary resources, and only if
all the prepare phase preparations succeed will the commit phase run.

The commit phase cannot error, because all of the resources have been
allocated successfully already.

This way there are no issues of "rolling back" because you never
actually move the state forward until you can guarantee that you can
do everything.
