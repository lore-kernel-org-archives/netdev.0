From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v3] stmmac: fix check for phydev being open
Date: Tue, 8 Sep 2015 12:46:28 +0000
Message-ID: <1441716387.21150.0.camel@synopsys.com>
References: <1441701786-10789-1-git-send-email-abrodkin@synopsys.com>
	 <55EEC462.2000906@cogentembedded.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:48204 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892AbbIHMqd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 08:46:33 -0400
In-Reply-To: <55EEC462.2000906@cogentembedded.com>
Content-Language: en-US
Content-ID: <567479D3913EA3498B9278FB44C0A048@internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Tue, 2015-09-08 at 14:20 +-0300, Sergei Shtylyov wrote:
+AD4- Hello.
+AD4- 
+AD4- On 9/8/2015 11:43 AM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- Current check of phydev with IS+AF8-ERR(phydev) may make not much sense
+AD4- +AD4- because of+AF8-phy+AF8-connect() returns NULL on failure instead of error value.
+AD4- +AD4- 
+AD4- +AD4- Still for checking result of phy+AF8-connect() IS+AF8-ERR() makes perfect sense.
+AD4- +AD4- 
+AD4- +AD4- So let's use combined check IS+AF8-ERR+AF8-OR+AF8-NULL() that covers both cases.
+AD4- +AD4- 
+AD4- +AD4- Cc: Sergei Shtylyov +ADw-sergei.shtylyov+AEA-cogentembedded.com+AD4-
+AD4- +AD4- Cc: Giuseppe Cavallaro +ADw-peppe.cavallaro+AEA-st.com+AD4-
+AD4- +AD4- Cc: linux-kernel+AEA-vger.kernel.org
+AD4- +AD4- Cc: stable+AEA-vger.kernel.org
+AD4- +AD4- Cc: David Miller +ADw-davem+AEA-davemloft.net+AD4-
+AD4- +AD4- Signed-off-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-
+AD4- +AD4- ---
+AD4- +AD4- 
+AD4- +AD4- Changes compared to v2:
+AD4- +AD4-   +ACo- Updated commit message with mention of of+AF8-phy+AF8-connect() instead of
+AD4- +AD4-     of+AF8-phy+AF8-attach().
+AD4- +AD4-   +ACo- Return ENODEV in case of of+AF8-phy+AF8-connect() failure
+AD4- +AD4- 
+AD4- +AD4- Changes compared to v1:
+AD4- +AD4-   +ACo- Use IS+AF8-ERR+AF8-OR+AF8-NULL() instead of discrete checks for null and err
+AD4- +AD4- 
+AD4- +AD4-   drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c +AHw- 7 +-+-+-+-+---
+AD4- +AD4-   1 file changed, 5 insertions(+-), 2 deletions(-)
+AD4- +AD4- 
+AD4- +AD4- diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- index 864b476..e2c9c86 100644
+AD4- +AD4- --- a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +-+-+- b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AEAAQA- -837,9 +-837,12 +AEAAQA- static int stmmac+AF8-init+AF8-phy(struct net+AF8-device +ACo-dev)
+AD4- +AD4-   				     interface)+ADs-
+AD4- +AD4-   	+AH0-
+AD4- +AD4- 
+AD4- +AD4- -	if (IS+AF8-ERR(phydev)) +AHs-
+AD4- +AD4- +-	if (IS+AF8-ERR+AF8-OR+AF8-NULL(phydev)) +AHs-
+AD4- +AD4-   		pr+AF8-err(+ACIAJQ-s: Could not attach to PHY+AFw-n+ACI-, dev-+AD4-name)+ADs-
+AD4- +AD4- -		return PTR+AF8-ERR(phydev)+ADs-
+AD4- +AD4- +-		if (+ACE-phydev)
+AD4- +AD4- +-			return -ENODEV+ADs-
+AD4- +AD4- +-		else
+AD4- +AD4- +-			return PTR+AF8-ERR(phydev)+ADs-
+AD4- 
+AD4-     Don't need +ACo-else+ACo- after +ACo-return+ACo- and scripts/checkpatch.pl should have 
+AD4- complained about that.

./scripts/checkpatch.pl 0001-stmmac-fix-check-for-phydev-being-open.patch 
total: 0 errors, 0 warnings, 0 checks, 14 lines checked

-Alexey