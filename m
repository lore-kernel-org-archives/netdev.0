From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: start hello timer only if device is up
Date: Thu, 01 Jun 2017 12:31:24 -0400 (EDT)
Message-ID: <20170601.123124.646097227290806863.davem@davemloft.net>
References: <06ef2ff1-f29d-a163-3226-7bd43c7a407c@cumulusnetworks.com>
        <1496329675-11254-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        lucien.xin@gmail.com, cera@cera.cz, sebott@linux.vnet.ibm.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdFAQbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:31:42 -0400
In-Reply-To: <1496329675-11254-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu,  1 Jun 2017 18:07:55 +0300

> When the transition of NO_STP -> KERNEL_STP was fixed by always calling
> mod_timer in br_stp_start, it introduced a new regression which causes
> the timer to be armed even when the bridge is down, and since we stop
> the timers in its ndo_stop() function, they never get disabled if the
> device is destroyed before it's upped.
> 
> To reproduce:
> $ while :; do ip l add br0 type bridge hello_time 100; brctl stp br0 on;
> ip l del br0; done;
> 
> CC: Xin Long <lucien.xin@gmail.com>
> CC: Ivan Vecera <cera@cera.cz>
> CC: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Fixes: 6d18c732b95c ("bridge: start hello_timer when enabling KERNEL_STP in br_stp_start")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable.
