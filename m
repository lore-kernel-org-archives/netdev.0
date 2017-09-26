From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,v3,net-next 0/2] Improve code coverage of syzkaller
Date: Mon, 25 Sep 2017 20:16:31 -0700 (PDT)
Message-ID: <20170925.201631.612115793478960027.davem@davemloft.net>
References: <20170922204915.7889-1-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com,
        willemb@google.com, ppenkov@stanford.edu
To: peterpenkov96@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934832AbdIZDQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:16:34 -0400
In-Reply-To: <20170922204915.7889-1-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petar Penkov <peterpenkov96@gmail.com>
Date: Fri, 22 Sep 2017 13:49:13 -0700

> This patch series is intended to improve code coverage of syzkaller on
> the early receive path, specifically including flow dissector, GRO,
> and GRO with frags parts of the networking stack. Syzkaller exercises
> the stack through the TUN driver and this is therefore where changes
> reside. Current coverage through netif_receive_skb() is limited as it
> does not touch on any of the aforementioned code paths. Furthermore,
> for full coverage, it is necessary to have more flexibility over the
> linear and non-linear data of the skbs.
> 
> The following patches address this by providing the user(syzkaller)
> with the ability to send via napi_gro_receive() and napi_gro_frags().
> Additionally, syzkaller can specify how many fragments there are and
> how much data per fragment there is. This is done by exploiting the
> convenient structure of iovecs. Finally, this patch series adds
> support for exercising the flow dissector during fuzzing.
> 
> The code path including napi_gro_receive() can be enabled via the
> IFF_NAPI flag.  The remainder of the changes in this patch series give
> the user significantly more control over packets entering the kernel.
> To avoid potential security vulnerabilities, hide the ability to send
> custom skbs and the flow dissector code paths behind a
> capable(CAP_NET_ADMIN) check to require special user privileges.
> 
> Changes since v2 based on feedback from Willem de Bruijn and Mahesh
> Bandewar:
> 
> Patch 1/ No changes.
> Patch 2/ Check if the preconditions for IFF_NAPI_FRAGS (IFF_NAPI and
> 	 IFF_TAP) are met before opening/attaching rather than after.
> 	 If they are not, change the behavior from discarding the
> 	 flag to rejecting the command with EINVAL.

Series applied, thank you.
