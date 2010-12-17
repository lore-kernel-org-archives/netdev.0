From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Fri, 17 Dec 2010 13:22:37 +0000
Message-ID: <1292592157.3136.819.camel@localhost>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
	 <20101129060114.GC29904@auslistsprd01.us.dell.com>
	 <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20101206173534.GC13628@auslistsprd01.us.dell.com>
	 <4CFD29BE.2060201@chelsio.com>
	 <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20101217024509.GA5854@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18079 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754077Ab0LQNWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:22:41 -0500
In-Reply-To: <20101217024509.GA5854@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 20:45 -0600, Matt Domsch wrote:
> On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
> > On Mon, 2010-12-06 at 10:21 -0800, Dimitris Michailidis wrote:
> > > Matt Domsch wrote:
> > ...
> > > /sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
> > > associated with.  At least a few drivers set up dev_id this way.
> > > 
> > > 
> > 
> > So we are on agreement? This can satisf all needs? If so, we will add
> > this scheme to the bnx2x as well.
> 
> I don't think that's enough.  Necessary, but not sufficient.
> 
> If dev_id is a field that starts over with each PCI device (e.g. is
> used to distinguish multiple ports that share the same PCI
> device), that's enough to handle the Chelsio case, but not the NPAR &
> SR-IOV case.
> 
> If the above is true, then a value of dev_id=0 for all 1:1 PCI Device
> : Port relations is fine, leaving the three drivers that set dev_id
> non-zero are all multi-port, single PCI device controllers.
> 
> cxgb4/t4_hw.c:          adap->port[i]->dev_id = j;
> mlx4/en_netdev.c:       dev->dev_id =  port - 1;
> sfc/siena.c:    efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
> 
> Is that truly how these three controllers work: they set dev_id when
> there are multiple physical ports that a single PCI d/b/d/f drives?
[...]

In the case of sfc, each port has a separate PCI function.  We read this
register field to find out which port we're talking to, as
virtualisation can alter the function number.  I don't know about the
others.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

