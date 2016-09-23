From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tcp: fix wrong checksum calculation on MTU probing
Date: Fri, 23 Sep 2016 07:58:39 -0400 (EDT)
Message-ID: <20160923.075839.1436905982520228085.davem@davemloft.net>
References: <2923a9bc-c433-7546-cd4a-9f834bd43181@taghos.com.br>
        <5ffc1020-a36f-75b4-ff25-4f58c243f803@cogentembedded.com>
        <f920ce68-c4e9-7772-809c-01f7319fa78e@taghos.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org
To: douglascs@taghos.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964954AbcIWL6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:58:49 -0400
In-Reply-To: <f920ce68-c4e9-7772-809c-01f7319fa78e@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Date: Thu, 22 Sep 2016 15:52:04 -0300

> With TCP MTU probing enabled and offload TX checksumming disabled,
> tcp_mtu_probe() calculated the wrong checksum when a fragment being copied
> into the probe's SKB had an odd length. This was caused by the direct use
> of skb_copy_and_csum_bits() to calculate the checksum, as it pads the
> fragment being copied, if needed. When this fragment was not the last, a
> subsequent call used the previous checksum without considering this
> padding.
> 
> The effect was a stale connection in one way, as even retransmissions
> wouldn't solve the problem, because the checksum was never recalculated for
> the full SKB length.
> 
> Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>

Applied and queued up for -stable, thanks.
