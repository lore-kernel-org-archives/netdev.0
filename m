From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH v3] sh_eth: use RNC mode for packet reception
Date: Tue, 03 Jun 2014 19:29:17 -0700 (PDT)
Message-ID: <20140603.192917.1491089262510239439.davem@davemloft.net>
References: <1401794473-30050-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@codethink.co.uk, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damm@opensource.se,
	horms@verge.net.au, yoshihiro.shimoda.uh@renesas.com,
	cm-hiep@jinso.co.jp
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaFDC3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:29:18 -0400
In-Reply-To: <1401794473-30050-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Tue,  3 Jun 2014 12:21:13 +0100

> The current behaviour of the sh_eth driver is not to use the RNC bit
> for the receive ring. This means that every packet recieved is not only
> generating an IRQ but it also stops the receive ring DMA as well until
> the driver re-enables it after unloading the packet.
> 
> This means that a number of the following errors are generated due to
> the receive packet FIFO overflowing due to nowhere to put packets:
> 
> 	net eth0: Receive FIFO Overflow
> 
> Since feedback from Yoshihiro Shimoda shows that every supported LSI
> for this driver should have the bit enabled it seems the best way is
> to remove the RMCR default value from the per-system data and just
> write it when initialising the RMCR value. This is discussed in
> the message (http://www.spinics.net/lists/netdev/msg284912.html).
> 
> I have tested the RMCR_RNC configuration with NFS root filesystem and
> the driver has not failed yet.  There are further test reports from
> Sergei Shtylov and others for both the R8A7790 and R8A7791.
> 
> There is also feedback fron Cao Minh Hiep[1] which reports the
> same issue in (http://comments.gmane.org/gmane.linux.network/316285)
> showing this fixes issues with losing UDP datagrams under iperf.
> 
> Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied.
