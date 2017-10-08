From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gso: fix payload length when gso_size is zero
Date: Sun, 08 Oct 2017 10:13:07 -0700 (PDT)
Message-ID: <20171008.101307.2029948180506638787.davem@davemloft.net>
References: <1507305755-14393-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        alexander.h.duyck@intel.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753842AbdJHRNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 13:13:08 -0400
In-Reply-To: <1507305755-14393-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri,  6 Oct 2017 19:02:35 +0300

> When gso_size reset to zero for the tail segment in skb_segment(), later
> in ipv6_gso_segment(), __skb_udp_tunnel_segment() and gre_gso_segment()
> we will get incorrect results (payload length, pcsum) for that segment.
> inet_gso_segment() already has a check for gso_size before calculating
> payload.
> 
> The issue was found with LTP vxlan & gre tests over ixgbe NIC.
> 
> Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
> v2: also added skb_is_gso to gre_gso_segment() and __skb_udp_tunnel_segment()
> 

Applied and queued up for -stable, thanks.
