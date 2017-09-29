From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] net/sched: support tunnel options in
 cls_flower and act_tunnel_key
Date: Fri, 29 Sep 2017 05:54:23 +0100 (WEST)
Message-ID: <20170929.055423.108055524887949393.davem@davemloft.net>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751224AbdI2Kvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 06:51:44 -0400
In-Reply-To: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed, 27 Sep 2017 10:16:32 +0200

> Users of options:
> 
> * There are eBPF hooks to allow getting on and setting tunnel metadata:
>   bpf_skb_set_tunnel_opt, bpf_skb_get_tunnel_opt.
> 
> * Open vSwitch is able to match and set Geneve and VXLAN-GBP options.
> 
> Neither of the above appear to assume any structure for the data.

I really worry about this.

These metadata option blobs are internal kernel datastructure which we
could change at any point in time.  They are not exported to
userspace as a UAPI.

It's kinda OK for eBPF programs to access this stuff since they are
expected to cope with changes to internal data-structures.

But for anything user facing, this really doesn't work.
