From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Sun, 04 Sep 2016 11:41:28 -0700 (PDT)
Message-ID: <20160904.114128.2287066969555349333.davem@davemloft.net>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, gospo@cumulusnetworks.com, vfalico@gmail.com,
        maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752138AbcIDSl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 14:41:29 -0400
In-Reply-To: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Thu,  1 Sep 2016 22:18:34 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Following few steps will crash kernel -
> 
>   (a) Create bonding master
>       > modprobe bonding miimon=50
>   (b) Create macvlan bridge on eth2
>       > ip link add link eth2 dev mvl0 address aa:0:0:0:0:01 \
> 	   type macvlan
>   (c) Now try adding eth2 into the bond
>       > echo +eth2 > /sys/class/net/bond0/bonding/slaves
>       <crash>
> 
> Bonding does lots of things before checking if the device enslaved is
> busy or not.
> 
> In this case when the notifier call-chain sends notifications, the
> bond_netdev_event() assumes that the rx_handler /rx_handler_data is
> registered while the bond_enslave() hasn't progressed far enough to
> register rx_handler for the new slave.
> 
> This patch adds a rx_handler check that can be performed right at the
> beginning of the enslave code to avoid getting into this situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied and queued up for -stable, thanks.
