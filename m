From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: em_meta: Fix 'meta vlan' to
 correctly recognize zero VID frames
Date: Sun, 23 Oct 2016 17:31:54 -0400 (EDT)
Message-ID: <20161023.173154.271949515698909625.davem@davemloft.net>
References: <1476998288-13341-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, jiri@resnulli.us,
        eric.dumazet@gmail.com, stephen@networkplumber.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbcJWVb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 17:31:59 -0400
In-Reply-To: <1476998288-13341-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Fri, 21 Oct 2016 00:18:08 +0300

> META_COLLECTOR int_vlan_tag() assumes that if the accel tag (vlan_tci)
> is zero, then no vlan accel tag is present.
> 
> This is incorrect for zero VID vlan accel packets, making the following
> match fail:
>   tc filter add ... basic match 'meta(vlan mask 0xfff eq 0)' ...
> 
> Apparently 'int_vlan_tag' was implemented prior VLAN_TAG_PRESENT was
> introduced in 05423b2 "vlan: allow null VLAN ID to be used"
> (and at time introduced, the 'vlan_tx_tag_get' call in em_meta was not
>  adapted).
> 
> Fix, testing skb_vlan_tag_present instead of testing skb_vlan_tag_get's
> value.
> 
> Fixes: 05423b2413 ("vlan: allow null VLAN ID to be used")
> Fixes: 1a31f2042e ("netsched: Allow meta match on vlan tag on receive")
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.
