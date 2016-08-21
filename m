From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: phy: Add missing of_node_put() in
 xgmiitorgmii_probe()
Date: Sun, 21 Aug 2016 15:29:15 -0700 (PDT)
Message-ID: <20160821.152915.360184359793857112.davem@davemloft.net>
References: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
        <20160820173605.GE30224@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752821AbcHUW3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 18:29:23 -0400
In-Reply-To: <20160820173605.GE30224@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 20 Aug 2016 19:36:05 +0200

> On Sat, Aug 20, 2016 at 03:26:55PM +0000, Wei Yongjun wrote:
>> This node pointer is returned by of_parse_phandle() with
>> refcount incremented in this function. of_node_put() on it
>> before exitting this function.
> 
> Hi Wei
> 
> You are only releasing on the error path. What about the successful
> path?

Agreed, as far as I can tell we do need to release it unconditionally
here.
