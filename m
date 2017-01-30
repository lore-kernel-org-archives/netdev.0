From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Avoid command timeouts during VF
 driver device shutdown
Date: Mon, 30 Jan 2017 15:45:40 -0500 (EST)
Message-ID: <20170130.154540.1823715181237721096.davem@davemloft.net>
References: <1485781905-1511-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com,
        jackm@dev.mellanox.co.il
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932067AbdA3Upm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:45:42 -0500
In-Reply-To: <1485781905-1511-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 30 Jan 2017 15:11:45 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> Some Hypervisors detach VFs from VMs by instantly causing an FLR event
> to be generated for a VF.
> 
> In the mlx4 case, this will cause that VF's comm channel to be disabled
> before the VM has an opportunity to invoke the VF device's "shutdown"
> method.
> 
> The result is that the VF driver on the VM will experience a command
> timeout during the shutdown process when the Hypervisor does not deliver
> a command-completion event to the VM.
> 
> To avoid FW command timeouts on the VM when the driver's shutdown method
> is invoked, we detect the absence of the VF's comm channel at the very
> start of the shutdown process. If the comm-channel has already been
> disabled, we cause all FW commands during the device shutdown process to
> immediately return success (and thus avoid all command timeouts).
> 
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied, thanks.
