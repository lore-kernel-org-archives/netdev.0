From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] HW checksum offload problem on Xilinx Zynq GEM
Date: Fri, 19 Aug 2016 12:28:39 -0700 (PDT)
Message-ID: <20160819.122839.1847374426262584384.davem@davemloft.net>
References: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, michal.simek@xilinx.com,
        netdev@vger.kernel.org, cyrille.pitchen@atmel.com
To: helmut.buchsbaum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754112AbcHST2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 15:28:43 -0400
In-Reply-To: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Date: Fri, 19 Aug 2016 15:04:57 +0200

> When working on upgrading the v3.x kernels of our embedded devices
> to more recent 4.x kernels we noticed some of our proprietary networking
> stuff is broken. Further investigations brought up an issue with small
> UDP packets (data payload <= 2), which contained wrong UDP header
> checksums.
> We tracked this down to commit 85ff3d87bf2ef1fadcde8553628c60f79806fdb4
> net/macb: add TX checksum offload feature. It turns out that Zynq's GEM
> is obviously buggy regarding the UDP checksum calculation of such small
> UDP packets as long as the UDP checksum field is != 0 *BEFORE* the
> HW calulation. But since udp_send_skb() *ALWAYS* calculates the UDP header
> checksum (unless disabled via socket option), this is the usual case.
> Unfortunately it does not respect the net device feature setting which
> would leave UDP checksum untouched when checksum offloading is enabled.

Then simply clear the checksum field in the driver, or fix
udp_send_skb() to do what you claim it is supposed to.

That seems like a much more appropriate fix to me.
