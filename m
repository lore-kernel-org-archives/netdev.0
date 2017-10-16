From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: cls_flower: Set egress_dev mark when
 calling into the HW driver
Date: Mon, 16 Oct 2017 21:20:32 +0100 (WEST)
Message-ID: <20171016.212032.2049244038001342016.davem@davemloft.net>
References: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org, mlxsw@mellanox.com,
        roid@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753257AbdJPUUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:20:34 -0400
In-Reply-To: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 16 Oct 2017 12:19:48 +0300

> Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress
> Hardware device') made sure (when fl_hw_replace_filter is called) to put
> the egress_dev mark on persisent structure instance. Hence, following calls
> into the HW driver for stats and deletion will note it and act accordingly.
> 
> With commit de4784ca030f this property is lost and hence when called,
> the HW driver failes to operate (stats, delete) on the offloaded flow.
> 
> Fix it by setting the egress_dev flag whenever the ingress device is
> different from the hw device since this is exactly the condition under
> which we're calling into the HW driver through the egress port net-device.
> 
> Fixes: de4784ca030f ('net: sched: get rid of struct tc_to_netdev')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> ---
> 
> Hi Dave, the bug was introduced in 4.14-rc1 but later the related
> code was changed in net-next, hence the fix must not go to net-next, Or.

Ok, applied to 'net' and I'll watch out for this next time I merge into
net-next.

Thanks.
