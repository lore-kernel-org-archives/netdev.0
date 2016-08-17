From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [Patch-V2 2/3] chcr: Support for Chelsio's Crypto Hardware
Date: Wed, 17 Aug 2016 11:21:37 +0530
Message-ID: <20160817055135.GA12749@hari-Latitude-E5550>
References: <1468906935-6770-1-git-send-email-yeshaswi@chelsio.com>
 <1468906935-6770-3-git-send-email-yeshaswi@chelsio.com>
 <20160719.211522.465417746785662817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <yeshaswi@chelsio.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-crypto@vger.kernel.org>,
	<jlulla@chelsio.ccom>, <harsh@chelsio.com>,
	<atul.gupta@chelsio.com>, <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719.211522.465417746785662817.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2016 at 09:15:22PM -0700, David Miller wrote:
> From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
> Date: Mon, 18 Jul 2016 22:42:14 -0700
> 
> > +config CRYPTO_DEV_CHELSIO
> > +	tristate "Chelsio Crypto Co-processor Driver"
> > +	depends on PCI && NETDEVICES && ETHERNET
> > +	select CRYPTO_SHA1
> > +	select CRYPTO_SHA256
> > +	select CRYPTO_SHA512
> > +	select NET_VENDOR_CHELSIO
> > +	select CHELSIO_T4
> 
> The user shouldn't have to know about the technical details about
> how this chip is physically implemented.
> 
> It's therefore not reasonable to require an ethernet driver to be
> enabled to use the crypto engine.
> 
> Also, selecting Kconfig symbol X does not recursively enable the
> "select" statement(s) of symbol X nor does it check symbol X's
> dependencies.
> 
> This is really one big huge dependency mess, and I think you have
> to split out the core of the T4 driver into a driver subtype
> agnostic library or similar to make this work properly.
> 
> Don't just shoehorn this stuff into the ethernet driver.  Round
> peg, square hole.
> 

Hi David,

We looked at the interface exposed by the current Ethernet driver and
how other drivers/protocols use that for exchanging control/data with
hardware. The cxgb4 driver is more than a Ethernet driver, it also
initializes the hardware so that other protocols can use them.
We have a terminology called lower level driver(LLD) and
Upper level driver(ULD). The lower level driver, which is cxgb4 acts
both as Ethernet driver and enables the hardware resources for ULD.
The ULD's such as iSCSI/iWARP/Crypto depends on lower level driver for the
initializied harware resources before processing the protocol specific part.

In v3 series of patch we have introduced common API framework for upper
level drivers to use the hardware resources. At present, all resouces are
allocated statically, no matter whether ULD is loaded or not. With the new
framework, all allocations and initialization for respective ULD's are done,
when they register with the LLD and freed when unregistered.
 
The ULD API framework makes the interface flexible and scalable for any new
driver which shall run on top of cxgb4. The v3 patch uses the new ULD APIs
introduced by cxgb4 only for crypto, and shall be extended further for
iSCSI and iWARP in upcoming series. The API also saves new driver(ULD) from
exclusively requesting the PCI function and manage the resources associated.

Thanks,
Hari
