From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] net: stmmac: fix stmmac_pci_probe failed when
 CONFIG_HAVE_CLK is selected
Date: Fri, 19 Sep 2014 09:52:21 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7EA4B1@PGSMSX102.gar.corp.intel.com>
References: <1411043650-31712-1-git-send-email-hock.leong.kweh@intel.com>
 <541AF116.9010004@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	Chen-Yu Tsai <wens@csie.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <541AF116.9010004@st.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> Sent: Thursday, September 18, 2014 10:50 PM
> On 9/18/2014 2:34 PM, Kweh Hock Leong wrote:
> > From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> Hmm I am not sure this is the right fix. The driver has to fail if the main clock is
> not found. Indeed dev_warn has to be changed in dev_err.
> 
> Take a look at Documentation/networking/stmmac.txt but I will post some
> patch to improve the documentation adding further detail for clocks too.
> 
> The the logic behind the code is that the CSR clock will be set at runtime if in
> case of priv->plat->clk_csr ==0 or it will be forced to a fixed value if passed
> from the platform instead of.
> IIRC This was required on some platforms time ago.
> For sure the driver is designed to fail in case of no main clock is found.
> 
> Peppe

Hi Peppe,

I understand your point from the code below (at file stmmac_main.c line 2784):

/* If a specific clk_csr value is passed from the platform
  * this means that the CSR Clock Range selection cannot be
  * changed at run-time and it is fixed. Viceversa the driver'll try to
  * set the MDC clock dynamically according to the csr actual
  * clock input.
  */
if (!priv->plat->clk_csr)
        stmmac_clk_csr_set(priv);
else
        priv->clk_csr = priv->plat->clk_csr;


I did search through the whole stmmac_main.c file and found that only stmmac_clk_csr_set()
function is leveraging the priv->stmmac_clk params for it calculation. By the logic point of
view, I do not need priv->stmmac_clk when I got priv->plat->clk_csr. With this thinking,
I propose this fix as when the probe get priv->plat->clk_csr, it shouldn't fail if priv->stmmac_clk
has the error value.


Regards,
Wilson
