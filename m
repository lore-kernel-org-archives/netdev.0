From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] bnx2x: avoid printing unnecessary
 messages during register dump
Date: Tue, 27 Sep 2016 22:43:49 -0400 (EDT)
Message-ID: <20160927.224349.354006077948089224.davem@davemloft.net>
References: <1475001234-25933-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, Yuval.Mintz@qlogic.com,
        netdev@vger.kernel.org
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753937AbcI1Cnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 22:43:52 -0400
In-Reply-To: <1475001234-25933-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Tue, 27 Sep 2016 15:33:54 -0300

> The bnx2x driver prints multiple error messages during register dump,
> with "ethtool -d" for example. The driver even warn that many messages
> might be seen during the register dump, but they are harmless. A typical
> kernel log after register dump looks like this:
> 
>   [9.375] bnx2x: [bnx2x_get_regs:987(net0)]Generating register dump. Might trigger harmless GRC timeouts
>   [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4342(net0)]LATCHED attention 0x04000000 (masked)
>   [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4346(net0)]GRC time-out 0x010580cd
>   [...]
> 
> The notation [...] means that some messages were supressed - in our
> tests we saw 78 more "LATCHED attention" and "GRC time-out" messages,
> supressed here.
> 
> This patch avoid these messages to be printed on register dump instead
> of just warn they are harmless.
> 
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Although "ethtool -d" is really a debugging facility, I still think that
serious care should be placed into arranging what gets dumped in such
a way that such access timeouts and errors are minimized.
