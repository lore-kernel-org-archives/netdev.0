From: Blaschka <frank.blaschka@de.ibm.com>
Subject: Re: [RFC] qeth: exploit gro for layer 3 driver
Date: Thu, 21 Jan 2010 14:48:45 +0100
Message-ID: <20100121134845.GA28645@tuxmaker.boeblingen.de.ibm.com>
References: <20100121123722.GA13815@tuxmaker.boeblingen.de.ibm.com> <20100121.051133.102632014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:45752 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab0AUNsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 08:48:47 -0500
Content-Disposition: inline
In-Reply-To: <20100121.051133.102632014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 05:11:33AM -0800, David Miller wrote:
> From: Blaschka <frank.blaschka@de.ibm.com>
> Date: Thu, 21 Jan 2010 13:37:22 +0100
> 
> > Since the qeth driver can not use NAPI I would like to hear
> > your opinion about following approach to exploit GRO.
> 
> Can you remind us why it can't use NAPI?
> 
> I personally find it hard to believe... :-)
Sure, let me try ...

on s/390 we neither have have a PCI bus nor a DMA transfer. We have
a common software component called qdio which does a DMA like data
transfer to/from the hardware. The inbound interface between qeth
and qdio is a tasklet running under the control of qdio. So the qeth
driver can not disable qdio IRQs (I guess this is a major reason why
not using NAPI) and poll the data.
qdio is also used for other s/390 non network drivers (e.g. fcp) so
changing this component is rather difficult and out of qeth scope.
The qdio framework already provides a bottomhalf so todays approach
to call netif_rx seems to be questionable anyway ...
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
