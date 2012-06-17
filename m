From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: Fix PHC loophole allowing misconfiguration of
 increment register
Date: Sun, 17 Jun 2012 16:16:29 -0700 (PDT)
Message-ID: <20120617.161629.894603261493065246.davem@davemloft.net>
References: <1339925340-26286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FQXQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:16:29 -0400
In-Reply-To: <1339925340-26286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 17 Jun 2012 02:29:00 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch fixes a potential hole when configuring the cycle counter used to
> generate the nanosecond time clock. This clock is based off of the SYSTIME
> registers along with the TIMINCA registers. The TIMINCA register determines
> the increment to be added to the SYSTIME registers every DMA clock tick. This
> register needs to be reconfigured whenever the link-speed changes. However,
> the value calculated stays the same when link is down and when link is up.
> Misconfiguration can occur if the link status changes due to a reset, which
> causes the TIMINCA register to be reset. This reset puts the device in an
> unstable state where the SYSTIME registers stop incrementing and the PTP
> protocol does not function.
> 
> The solution is to double check the TIMINCA value and always reset the value
> if the register is zero. This prevents a misconfiguration bug that halts the
> PHC.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
