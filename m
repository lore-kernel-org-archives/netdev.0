From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Avoid delays during VF driver
 device shutdown
Date: Thu, 16 Mar 2017 20:16:00 -0700 (PDT)
Message-ID: <20170316.201600.1967474925238950208.davem@davemloft.net>
References: <1489426148-7906-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com,
        jackm@dev.mellanox.co.il
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdCQDQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:16:29 -0400
In-Reply-To: <1489426148-7906-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 13 Mar 2017 19:29:08 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> Some Hypervisors detach VFs from VMs by instantly causing an FLR event
> to be generated for a VF.
> 
> In the mlx4 case, this will cause that VF's comm channel to be disabled
> before the VM has an opportunity to invoke the VF device's "shutdown"
> method.
> 
> For such Hypervisors, there is a race condition between the VF's
> shutdown method and its internal-error detection/reset thread.
> 
> The internal-error detection/reset thread (which runs every 5 seconds) also
> detects a disabled comm channel. If the internal-error detection/reset
> flow wins the race, we still get delays (while that flow tries repeatedly
> to detect comm-channel recovery).
> 
> The cited commit fixed the command timeout problem when the
> internal-error detection/reset flow loses the race.
> 
> This commit avoids the unneeded delays when the internal-error
> detection/reset flow wins.
> 
> Fixes: d585df1c5ccf ("net/mlx4_core: Avoid command timeouts during VF driver device shutdown")
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Reported-by: Simon Xiao <sixiao@microsoft.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied.
