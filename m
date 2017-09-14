From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] sctp: potential read out of bounds in
 sctp_ulpevent_type_enabled()
Date: Wed, 13 Sep 2017 17:00:19 -0700 (PDT)
Message-ID: <20170913.170019.543516362575770735.davem@davemloft.net>
References: <20170913.092522.934509429497822082.davem@davemloft.net>
        <20170913230054.fmtidvfi2swvy2mm@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdINAA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 20:00:26 -0400
In-Reply-To: <20170913230054.fmtidvfi2swvy2mm@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 14 Sep 2017 02:00:54 +0300

> This code causes a static checker warning because Smatch doesn't trust
> anything that comes from skb->data.  I've reviewed this code and I do
> think skb->data can be controlled by the user here.
> 
> The sctp_event_subscribe struct has 13 __u8 fields and we want to see
> if ours is non-zero.  sn_type can be any value in the 0-USHRT_MAX range.
> We're subtracting SCTP_SN_TYPE_BASE which is 1 << 15 so we could read
> either before the start of the struct or after the end.
> 
> This is a very old bug and it's surprising that it would go undetected
> for so long but my theory is that it just doesn't have a big impact so
> it would be hard to notice.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2:  Use reverse-christmas-tree local variable ordering.

Applied and queued up for -stable, thanks.
