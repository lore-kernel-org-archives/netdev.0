From: <srinivas.kandagatla@st.com>
Subject: [PATCH v3 0/3] net: stmmac: Add STi GMAC ethernet
Date: Tue, 11 Feb 2014 09:58:36 +0000
Message-ID: <1392112716-30803-1-git-send-email-srinivas.kandagatla@st.com>
References: <1391770455-24291-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, kernel@stlinux.com,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Srinivas Kandagatla <srinivas.kandagatla@st.com>, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, Stuart Menefy <stuart.menefy@st.com>,
 Rob Herring <robh+dt@kernel.org>, Rob Landley <rob@landley.net>,
 Kumar Gala <galak@codeaurora.org>, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1391770455-24291-1-git-send-email-srinivas.kandagatla@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Hi All,

This patch series adds Ethernet support to STi series SOCs STiH415 and STiH416.
STi SOC series integrates dwmac IP from synopsis, however there is a hardware
glue on top of this standard IP, this glue needs to configured before the
actual dwmac can be used.  Also the glue logic needs re-configuring when the
link speed changes, This is because the clk source can change as the link
speed changes.

This patch just adds STi specific callbacks into of_data for configuring the
glue layer.

I have rebased my original patches (http://lkml.org/lkml/2013/11/12/243)
to latest stmmac which updates callbacks to suit glue drivers like this.

These patches are tested on b2000 and B2020 with STiH415 and STiH416.

Changes since v1:
 - fixed multi-line function call format as suggested by David Miller.

Changes since v2:
 - fix indenting issues & superfluous empty lines as suggested by David Miller.
 - Run the code through scripts/Lindent.

Dave, Can I request you to take the first patch via net tree for v3.15, I can
request Arnd or Olof to take the DT patches via the arm-soc tree for v3.15.

Thanks,
srini

Srinivas Kandagatla (3):
  net: stmmac:sti: Add STi SOC glue driver.
  ARM: STi: Add STiH415 ethernet support.
  ARM: STi: Add STiH416 ethernet support.

 .../devicetree/bindings/net/sti-dwmac.txt          |   58 ++++
 arch/arm/boot/dts/stih415-clock.dtsi               |   14 +
 arch/arm/boot/dts/stih415-pinctrl.dtsi             |  121 +++++++
 arch/arm/boot/dts/stih415.dtsi                     |   48 +++
 arch/arm/boot/dts/stih416-clock.dtsi               |   14 +
 arch/arm/boot/dts/stih416-pinctrl.dtsi             |  109 +++++++
 arch/arm/boot/dts/stih416.dtsi                     |   44 +++
 arch/arm/boot/dts/stih41x-b2000.dtsi               |   22 ++
 arch/arm/boot/dts/stih41x-b2020.dtsi               |   26 ++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  330 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    5 +
 14 files changed, 806 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c

-- 
1.7.9.5
