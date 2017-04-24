From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: disable inner UDP checksum offloads in IPsec
 case
Date: Mon, 24 Apr 2017 13:49:13 -0400 (EDT)
Message-ID: <20170424.134913.859328581317183203.davem@davemloft.net>
References: <1492813385-31736-1-git-send-email-aatteka@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aatteka@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S973087AbdDXRtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:49:14 -0400
In-Reply-To: <1492813385-31736-1-git-send-email-aatteka@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@ovn.org>
Date: Fri, 21 Apr 2017 15:23:05 -0700

> Otherwise, UDP checksum offloads could corrupt ESP packets by attempting
> to calculate UDP checksum when this inner UDP packet is already protected
> by IPsec.
> 
> One way to reproduce this bug is to have a VM with virtio_net driver (UFO
> set to ON in the guest VM); and then encapsulate all guest's Ethernet
> frames in Geneve; and then further encrypt Geneve with IPsec.  In this
> case following symptoms are observed:
> 1. If using ixgbe NIC, then it will complain with following error message:
>    ixgbe 0000:01:00.1: partial checksum but l4 proto=32!
> 2. Receiving IPsec stack will drop all the corrupted ESP packets and
>    increase XfrmInStateProtoError counter in /proc/net/xfrm_stat.
> 3. iperf UDP test from the VM with packet sizes above MTU will not work at
>    all.
> 4. iperf TCP test from the VM will get ridiculously low performance because.
> 
> Signed-off-by: Ansis Atteka <aatteka@ovn.org>
> Co-authored-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
