From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCHv2 net-next 1/3] net: Add provision to specify pf number
 while assigning VF mac
Date: Tue, 19 Jul 2016 13:10:06 +0530
Message-ID: <20160719074004.GA29269@hari-Latitude-E5550>
References: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
 <1467300884-32340-2-git-send-email-hariprasad@chelsio.com>
 <CO2PR11MB0088BB6334851B5B51E5851497240@CO2PR11MB0088.namprd11.prod.outlook.com>
 <20160701031055.GA29804@hari-Latitude-E5550>
 <CO2PR11MB0088CA97ED5A2EC7D964536097250@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:11530 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752202AbcGSHlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 03:41:31 -0400
Content-Disposition: inline
In-Reply-To: <CO2PR11MB0088CA97ED5A2EC7D964536097250@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2016 at 04:41:52 +0000, Yuval Mintz wrote:
> > > > Chelsio T4/T5 cards have SR-IOV Capabilities on Physical Functions
> > > > 0..3 and the administrative Driver(cxgb4) attaches to Physical Function 4.
> > > > Each of the Physical Functions 0..3 can support up to 16 Virtual
> > > > Functions. With the current Linux APIs, a 2-Port card would only be
> > > > able to use the Virtual Functions on Physical Functions 0..1 and not
> > > > allow the Virtual Functions on Physical Functions 2..3 to be used since
> > > > there are no Ports 2..3 on a 2-Port card.
> > > >
> > > > Also the current ip commands takes netdev as one of the argument, and
> > > > it assumes a 1-to-1 mapping of Network Ports, Physical Functions and the
> > > > SR-IOV Virtual Functions of those Physical Functions. But it is not
> > > > true in our case and won't work for us.
> > > >
> > > > Added a new argument to specify the PF number associated with the VF, to
> > > > fix this.
> > >
> > > I don't get it - what's the exact definition of 'Physical Function'?
> > > Are we talking PCI functions? Logical partitons? Something else?
> 
> > Its PCIe physical function. Physical functions (PFs) are full-featured
> > PCIe functions; virtual functions (VFs) are "lightweight" functions that
> > lack configuration resource.
> 
> Seems like a bad precedent to me - the control node is always the netdevice.
> While I understand your need, looks like what you really want some kind of
> a dummy netdevice for the higher PFs through which you could control their
> VFs.

Hi Dave and all,

Based on above comment, since the control node should always be net_device, we
will go with the below implementation.

We will have dummy net devices with 00:00:00:00:00:00 mac address. The device
won't be associated with any port, since it doesn't need to transmit/receive.
On a two port adapter, we need to create 4 dummy net devices, corresponding to
PF0 ... PF3. Basically the dummy net device will have  callback's only 
for "ndo_set_vf_*" API's.

Thanks,
Hariprasad Shenai
