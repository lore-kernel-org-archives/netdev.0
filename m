From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 2 Apr 2013 23:15:24 +0200
Message-ID: <20130402211524.GE4924@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com> <20100125.163612.582489483209420341.anders@netinsight.net> <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com> <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46974 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758910Ab3DBVP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 17:15:26 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 01, 2013 at 02:51:56AM +0000, Huang, Xiong wrote:
> > >
> > > I checked windows driver, it does limit  the max packet length for TSO
> > > windows XP : 32*1024 bytes (include MAC header and all MAC payload). No
> > support IP/TCP option.
> > > Windows 7:  15, 000 bytes, support IP/TCP option.
> > 
> > If TSO on these devices don't work properly with TCP options then you're
> > just going to have to disable it - Linux requires it to support at least the
> > timestamp option.  I'm not sure about IP options (this really ought to be
> > documented).
> > 
> > If there's a length limit lower than 64K, you'll need to set the limit using
> > netif_set_gso_max_size() before registering the net device.
> > 
> 
> Ben, thanks for your advice. 
> I have discussed with windows driver developer and hardware designer, the TSO limitation for win driver is just
> For simplifying windows driver due to the buffer length limitation of TX descriptor. The hardware itself has no limitation on
> TSO packet length.

The error vanishes as soon as I put a gso size limit of MAX_TX_BUF_LEN
in the driver. MAX_TX_BUF_LEN seems to be arbitrary set to 0x2000. I
can even raise it to 0x3000 and don't see any tcp retransmits. Do you
have an advice on how to size this value (e.g. should we switch to the
windows values)?

I also found some irregularities in the mtu update code. It differs from the
calculations in the init function (I will send a patch for that).
