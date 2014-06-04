From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC/PATCH v3] sh_eth: use RNC mode for packet reception
Date: Wed, 4 Jun 2014 10:26:56 +0900
Message-ID: <20140604012656.GE25936@verge.net.au>
References: <1401794473-30050-1-git-send-email-ben.dooks@codethink.co.uk>
 <538E685A.1000505@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@codethink.co.uk, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damm@opensource.se,
	cm-hiep@jinso.co.jp
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57411 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaFDB07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 21:26:59 -0400
Content-Disposition: inline
In-Reply-To: <538E685A.1000505@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2014 at 09:29:14AM +0900, Yoshihiro Shimoda wrote:
> Hi Ben,
> 
> (2014/06/03 20:21), Ben Dooks wrote:
> > The current behaviour of the sh_eth driver is not to use the RNC bit
> > for the receive ring. This means that every packet recieved is not only
> > generating an IRQ but it also stops the receive ring DMA as well until
> > the driver re-enables it after unloading the packet.
> > 
> > This means that a number of the following errors are generated due to
> > the receive packet FIFO overflowing due to nowhere to put packets:
> > 
> > 	net eth0: Receive FIFO Overflow
> > 
> > Since feedback from Yoshihiro Shimoda shows that every supported LSI
> > for this driver should have the bit enabled it seems the best way is
> > to remove the RMCR default value from the per-system data and just
> > write it when initialising the RMCR value. This is discussed in
> > the message (http://www.spinics.net/lists/netdev/msg284912.html).
> > 
> > I have tested the RMCR_RNC configuration with NFS root filesystem and
> > the driver has not failed yet.  There are further test reports from
> > Sergei Shtylov and others for both the R8A7790 and R8A7791.
> > 
> > There is also feedback fron Cao Minh Hiep[1] which reports the
> > same issue in (http://comments.gmane.org/gmane.linux.network/316285)
> > showing this fixes issues with losing UDP datagrams under iperf.
> > 
> > Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> > Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
> Thank you very much for the patch.
> 
> Acked-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

If this patch is fine by Shimoda-san then its fine be me too.

Acked-by: Simon Horman <horms+renesas@verge.net.au>
