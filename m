From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Wed, 14 Mar 2012 13:07:55 +0000
Message-ID: <201203141307.55808.arnd@arndb.de>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
 <20120312143825.GB13869@game.jcrosoft.org> <4F60832E.6060100@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>, Stefan Roese <sr@denx.de>,
 Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
 devicetree-discuss@ozlabs.org, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4F60832E.6060100@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 March 2012, Giuseppe CAVALLARO wrote:
> On 3/12/2012 3:38 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 15:05 Mon 12 Mar     , Stefan Roese wrote:
> >> This patch adds support to configure the STMMAC ethernet driver via
> >> device-tree instead of platform_data.
> >>
> >> Currently, only the properties needed on SPEAr600 are provided. All
> >> other properties should be added once needed on other platforms.
> >>
> >> Signed-off-by: Stefan Roese <sr@denx.de>
> >> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >> Cc: Viresh Kumar <viresh.kumar@st.com>
> >> ---
> >>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
> >>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66 +++++++++++++++++++-
> >>  2 files changed, 103 insertions(+), 1 deletion(-)
> >>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> >> new file mode 100644
> >> index 0000000..386a47f
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> >> @@ -0,0 +1,38 @@
> >> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> >> +
> >> +Required properties:
> >> +- compatible: Should be "stm,gmac"
> 
> > this IP have 2 version at least the GMAC for the second generation and mac for
> > the first generation
> 
> yes you are right. STMMAC supports two device generations I named:
> dwma10/100 and dwmac1000 (gmac).
> 
> Concerning the latter, we support several different versions of the
> synopsys GMAC cores ... from 3.30 to 3.61a.
> 
> For example, stx7108 and Stx7109 have the same GMAC core (also SPEAr600
> IIRC).
> SPEAr13xx has 3.50a
> New ST SoC Stxh415 has the 3.60a. etc.

In that case, you should definitely list the exact device versions in the
compatible string, like:

compatible = "stm,spear600-gmac", "snps,dw-gmac-3.50a", "snps,dw-gmac";

When we have other socs with the same version, that lets us add quirks
for the specific version by checking the compatible property once in the
driver.

It also sounds to me that the entire stmmac driver should live in the
drivers/net/ethernet/synopsys directory, not stmicro, but that is a
different issue.


	Arnd
