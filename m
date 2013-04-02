From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Wed, 3 Apr 2013 00:19:13 +0200
Message-ID: <20130402221913.GG4924@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com> <20100125.163612.582489483209420341.anders@netinsight.net> <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com> <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com> <20130402211524.GE4924@order.stressinduktion.org> <157393863283F442885425D2C45428564F202AD5@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47107 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933790Ab3DBWTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 18:19:15 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F202AD5@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 09:51:12PM +0000, Huang, Xiong wrote:
> > The error vanishes as soon as I put a gso size limit of MAX_TX_BUF_LEN in
> > the driver. MAX_TX_BUF_LEN seems to be arbitrary set to 0x2000. I can even
> > raise it to 0x3000 and don't see any tcp retransmits. Do you have an advice on
> > how to size this value (e.g. should we switch to the windows values)?
> > 
> 
> Would you try 0x4000 ? because the buffer-length in TX descriptor is 14bits, 0x4000 exceeds max value.
> Do you find any bug/issue on the code that calculate the length for each TX descriptor ?

Setting MAX_TX_BUF_LEN to 0x4000

[ 8949.833750] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[ 8949.833783] IPv6: ADDRCONF(NETDEV_CHANGE): p33p1: link becomes ready
[ 8960.861557] ATL1E 0000:04:00.0 p33p1: PCIE DMA RW error (status = 0x5000400)
[ 8960.866879] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[ 8961.095266] ATL1E 0000:04:00.0 p33p1: PCIE DMA RW error (status = 0x5000400)
[ 8961.100791] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>

I have not looked at the buffer calculations intensly.
