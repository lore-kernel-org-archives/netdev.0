From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlxsw: spectrum: Implement the ethtool
 flash_device callback
Date: Thu, 01 Jun 2017 12:25:55 -0400 (EDT)
Message-ID: <20170601.122555.1824969925686772266.davem@davemloft.net>
References: <20170601132646.51869-1-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        ogerlitz@mellanox.com, ilant@mellanox.com, jiri@mellanox.com,
        arkadis@mellanox.com
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdFAQ0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:26:03 -0400
In-Reply-To: <20170601132646.51869-1-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Thu,  1 Jun 2017 16:26:46 +0300

> Add callback to the ethtool flash_device op. This callback uses the mlxfw
> module to flash the new firmware file to the device.
> 
> As the firmware flash process takes about 20 seconds and ethtool takes the
> rtnl lock during the flash_device callback, release the rtnl lock at the
> beginning of the flash process and take it again before leaving the
> callback. This way, the rtnl is not held during the process. To make sure
> the device does not get deleted during the flash process, take a reference
> to it before releasing the rtnl lock.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

You're going to have to implement some kind of sleeping synchronization
then, in order to prevent another thread coming in and starting another
flash at the same time.

Nevermind, I see you have to take the FSM lock to start the flash
operation so it should be fine.

Applied, thanks.
