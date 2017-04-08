From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Support to enable LSO/CSO for Trunk VEA.
Date: Sat, 08 Apr 2017 11:45:15 -0700 (PDT)
Message-ID: <20170408.114515.1339820744697810446.davem@davemloft.net>
References: <1491559079-10855-1-git-send-email-ksiva@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        brking@linux.vnet.ibm.com, seroyer@linux.vnet.ibm.com
To: ksiva@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751955AbdDHSpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:45:19 -0400
In-Reply-To: <1491559079-10855-1-git-send-email-ksiva@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
Date: Fri,  7 Apr 2017 05:57:59 -0400

> Enable largesend and checksum offload for ibmveth configured in trunk mode.
> Added support to SKB frag_list in TX path by skb_linearize'ing such SKBs.
> 
> Signed-off-by: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>

Why is linearization necessary?

It would seem that the gains you get from GRO are nullified by
linearizing the SKB and thus copying all the data around and
allocating buffers.

Finally, all of that new checksumming stuff looks extremely
suspicious.  You have to explain why that is happening and why it
isn't because this driver is doing something incorrectly.

Thanks.
