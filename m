From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 12:27:11 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Federico Vaga <federico.vaga@gmail.com>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> -----Original Message-----
> From: Stephen Rothwell [mailto:sfr@canb.auug.org.au]
> Sent: Wednesday, June 20, 2012 9:04 AM
> To: David Miller; netdev@vger.kernel.org
> Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Federico
> Vaga; Giancarlo ASNAGHI; Wolfgang Grandegger; Bhupesh SHARMA; Marc
> Kleine-Budde
> Subject: linux-next: build failure after merge of the net-next tree
> 
> Hi all,
> 
> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_get" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_put" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> 
> Caused by commit 5b92da0443c2 ("c_can_pci: generic module for
> C_CAN/D_CAN on PCI").  Maybe a missing Kconfig dependency/select?
> 
> I have used the net-next tree from next-20120619 for today.
> --

clk_get/clk_put* variants are usually used by ARM platforms.
Protecting their calls under macro 'CONFIG_HAVE_CLK' should solve the problem.

See [1] for how it is done in c_can_platform.c

Could you possibly add these checks and send a patch for the same?
It should be fairly simple.

[1] http://lxr.linux.no/linux+v3.4.3/drivers/net/can/c_can/c_can_platform.c#L68

Regards,
Bhupesh
