From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: always use the current L2 addr of the
 master
Date: Thu, 12 Oct 2017 22:54:35 -0700 (PDT)
Message-ID: <20171012.225435.505421146573578124.davem@davemloft.net>
References: <20171012001626.3255-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdJMFyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 01:54:39 -0400
In-Reply-To: <20171012001626.3255-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 11 Oct 2017 17:16:26 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> If the underlying master ever changes its L2 (e.g. bonding device),
> then make sure that the IPvlan slaves always emit packets with the
> current L2 of the master instead of the stale mac addr which was
> copied during the device creation. The problem can be seen with
> following script -
> 
>   #!/bin/bash
>   # Create a vEth pair
>   ip link add dev veth0 type veth peer name veth1
>   ip link set veth0 up
>   ip link set veth1 up
>   ip link show veth0
>   ip link show veth1
>   # Create an IPvlan device on one end of this vEth pair.
>   ip link add link veth0 dev ipvl0 type ipvlan mode l2
>   ip link show ipvl0
>   # Change the mac-address of the vEth master.
>   ip link set veth0 address 02:11:22:33:44:55
> 
> Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
