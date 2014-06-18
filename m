From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Don't clear IPV6 header checksum field when
 IP accelerator enable
Date: Tue, 17 Jun 2014 21:58:54 -0700 (PDT)
Message-ID: <20140617.215854.1779406060920309523.davem@davemloft.net>
References: <1403051632-32113-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaFRE65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 00:58:57 -0400
In-Reply-To: <1403051632-32113-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 18 Jun 2014 08:33:52 +0800

> The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
> enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
> cannot work. (The issue is reported by Russell King)
> 
> For FEC IP header checksum function: Insert IP header checksum. This "IINS"
> bit is written by the user. If set, IP accelerator calculates the IP header
> checksum and overwrites the IINS corresponding header field with the calculated
> value. The checksum field must be cleared by user, otherwise the checksum
> always is 0xFFFF.
> 
> So the previous patch clear IP header checksum field regardless of IP frame
> type.
> 
> In fact, IP HW detect the packet as IPV6 type, even if the "IINS" bit is set,
> the IP accelerator is not triggered to calculates IPV6 header checksum because
> IPV6 frame format don't have checksum.
> 
> So this results in the IPV6 frame being corrupted.
> 
> The patch just add software detect the current packet type, if it is IPV6
> frame, it don't clear IP header checksum field.
> 
> Cc: Russell King <linux@arm.linux.org.uk>
> Reported-and-tested-by: Russell King <linux@arm.linux.org.uk>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thank you.
