From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] stmmac: fix check for phydev being open
Date: Mon, 7 Sep 2015 21:08:17 +0000
Message-ID: <1441660096.4998.1.camel@synopsys.com>
References: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
	 <55EDF930.10601@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55EDF930.10601@cogentembedded.com>
Content-Language: en-US
Content-ID: <A57D41AAD6C4414C9E9511F3ECF1A46D@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Mon, 2015-09-07 at 23:53 +-0300, Sergei Shtylyov wrote:
+AD4- On 09/07/2015 11:50 PM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- Current implementation via IS+AF8-ERR(phydev) may make no sense because
+AD4- +AD4- of+AF8-phy+AF8-attach() returns NULL on failure instead of error value.
+AD4- +AD4- 
+AD4- +AD4- Still for checking result of phy+AF8-connect() IS+AF8-ERR() is useful.
+AD4- +AD4- 
+AD4- +AD4- To address both situations we use combined IS+AF8-ERR+AF8-OR+AF8-NULL() check.
+AD4- +AD4- 
+AD4- +AD4- Cc: Giuseppe Cavallaro +ADw-peppe.cavallaro+AEA-st.com+AD4-
+AD4- +AD4- Cc: linux-kernel+AEA-vger.kernel.org
+AD4- +AD4- Cc: stable+AEA-vger.kernel.org
+AD4- +AD4- Cc: David Miller +ADw-davem+AEA-davemloft.net+AD4-
+AD4- +AD4- Cc: Sergei Shtylyov +ADw-sergei.shtylyov+AEA-cogentembedded.com+AD4-
+AD4- +AD4- Signed-off-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-
+AD4- +AD4- ---
+AD4- +AD4- 
+AD4- +AD4- Changes compared to v1:
+AD4- +AD4-   +ACo- Use IS+AF8-ERR+AF8-OR+AF8-NULL() instead of discrete checks for null and err
+AD4- +AD4- 
+AD4- +AD4-   drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c +AHw- 2 +--
+AD4- +AD4-   1 file changed, 1 insertion(+-), 1 deletion(-)
+AD4- +AD4- 
+AD4- +AD4- diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- index 864b476..7985d8a 100644
+AD4- +AD4- --- a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +-+-+- b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AEAAQA- -837,7 +-837,7 +AEAAQA- static int stmmac+AF8-init+AF8-phy(struct net+AF8-device +ACo-dev)
+AD4- +AD4-   				     interface)+ADs-
+AD4- +AD4-   	+AH0-
+AD4- +AD4- 
+AD4- +AD4- -	if (IS+AF8-ERR(phydev)) +AHs-
+AD4- +AD4- +-	if (IS+AF8-ERR+AF8-OR+AF8-NULL(phydev)) +AHs-
+AD4- +AD4-   		pr+AF8-err(+ACIAJQ-s: Could not attach to PHY+AFw-n+ACI-, dev-+AD4-name)+ADs-
+AD4- +AD4-   		return PTR+AF8-ERR(phydev)+ADs-
+AD4- 
+AD4-     Hm, in case of phydev +AD0APQ- NULL, you're going to return 0 here... is that 
+AD4- what you want?

Ah, right.

So then the question would be what's a proper error code for +ACE-phydev:
-ENOENT or -ENODEV?

-Alexey