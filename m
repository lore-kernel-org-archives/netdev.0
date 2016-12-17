From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vrf: Drop conntrack data after pass through
 VRF device on Tx
Date: Sat, 17 Dec 2016 10:48:44 -0500 (EST)
Message-ID: <20161217.104844.318907325452419548.davem@davemloft.net>
References: <1481754671-22519-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754218AbcLQPsq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:48:46 -0500
In-Reply-To: <1481754671-22519-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 14 Dec 2016 14:31:11 -0800

> Locally originated traffic in a VRF fails in the presence of a POSTROUTING
> rule. For example,
> 
>     $ iptables -t nat -A POSTROUTING -s 11.1.1.0/24  -j MASQUERADE
>     $ ping -I red -c1 11.1.1.3
>     ping: Warning: source address might be selected on device other than red.
>     PING 11.1.1.3 (11.1.1.3) from 11.1.1.2 red: 56(84) bytes of data.
>     ping: sendmsg: Operation not permitted
> 
> Worse, the above causes random corruption resulting in a panic in random
> places (I have not seen a consistent backtrace).
> 
> Call nf_reset to drop the conntrack info following the pass through the
> VRF device.  The nf_reset is needed on Tx but not Rx because of the order
> in which NF_HOOK's are hit: on Rx the VRF device is after the real ingress
> device and on Tx it is is before the real egress device. Connection
> tracking should be tied to the real egress device and not the VRF device.
> 
> Fixes: 8f58336d3f78a ("net: Add ethernet header for pass through VRF device")
> Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
