From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: CSR clock configuration fix
Date: Wed, 21 Dec 2016 13:21:04 -0500 (EST)
Message-ID: <20161221.132104.1026207180067066991.davem@davemloft.net>
References: <6d4c6d15a60c93a8aef5e3e03b9cd64cdcf232c8.1482232420.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, hock.leong.kweh@intel.com,
        niklas.cassel@axis.com, pavel@ucw.cz, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6d4c6d15a60c93a8aef5e3e03b9cd64cdcf232c8.1482232420.git.jpinto@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 20 Dec 2016 11:21:47 +0000

> When testing stmmac with my QoS reference design I checked a problem in the
> CSR clock configuration that was impossibilitating the phy discovery, since
> every read operation returned 0x0000ffff. This patch fixes the issue.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

This isn't enough.

It looks like various parts of this driver set the mask field
differently.

dwmac1000_core.c and dwmac100_core.c set the mask to be the low bits.

But dwmac4_core.c uses GENMASK(11, 8) which means the mask is a value
which is shifted up already.

So your patch will break chips driven by dwmac4_core.c.

In order for your change to be correct you must consolidate all of
these various pieces to use the same convention.
