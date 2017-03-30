From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ixgbe: Check for skb->queue_mapping
Date: Wed, 29 Mar 2017 17:29:47 -0700
Message-ID: <1490833787.24891.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490831714-6184-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34016 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933226AbdC3A34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 20:29:56 -0400
Received: by mail-pg0-f53.google.com with SMTP id 21so22233094pgg.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 17:29:55 -0700 (PDT)
In-Reply-To: <1490831714-6184-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 16:55 -0700, Tushar Dave wrote:
> There are events seen where skb->queue_mapping value is greater than
> adapter->num_tx_queue. In such cases, adapter->tx_ring becomes invalid
> (null) and xmit results in kernel panic.
> 
> One such event is running netconsole and enabling VF on the same device.
> Or running netconsole and changing number of tx queues via ethtool on
> same device.
> 
> This patch adds check for skb->queue_mapping and uses simple arithmetic
> to select available tx queue from driver.

We are not going to fix all multi queue drivers, for something that
seems to be a generic issue higher in the stack.
