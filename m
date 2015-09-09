From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v3] stmmac: fix check for phydev being open
Date: Wed, 9 Sep 2015 14:44:51 +0000
Message-ID: <1441809891.15399.18.camel@synopsys.com>
References: <1441701786-10789-1-git-send-email-abrodkin@synopsys.com>
	 <55EEC462.2000906@cogentembedded.com>
	 <1441716387.21150.0.camel@synopsys.com>
	 <55EF3CCF.4000608@cogentembedded.com>
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
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <55EF3CCF.4000608@cogentembedded.com>
Content-Language: en-US
Content-ID: <3181C10F96C7F244B7969A1B34BA38A6@internal.synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Tue, 2015-09-08 at 22:53 +-0300, Sergei Shtylyov wrote:
+AD4- Hello.
+AD4- 
+AD4- On 09/08/2015 03:46 PM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- +AD4- +AD4- Current check of phydev with IS+AF8-ERR(phydev) may make not much sense
+AD4- +AD4- +AD4- +AD4- because of+AF8-phy+AF8-connect() returns NULL on failure instead of error value.
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Still for checking result of phy+AF8-connect() IS+AF8-ERR() makes perfect sense.
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- So let's use combined check IS+AF8-ERR+AF8-OR+AF8-NULL() that covers both cases.
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Cc: Sergei Shtylyov +ADw-sergei.shtylyov+AEA-cogentembedded.com+AD4-
+AD4- +AD4- +AD4- +AD4- Cc: Giuseppe Cavallaro +ADw-peppe.cavallaro+AEA-st.com+AD4-
+AD4- +AD4- +AD4- +AD4- Cc: linux-kernel+AEA-vger.kernel.org
+AD4- +AD4- +AD4- +AD4- Cc: stable+AEA-vger.kernel.org
+AD4- +AD4- +AD4- +AD4- Cc: David Miller +ADw-davem+AEA-davemloft.net+AD4-
+AD4- +AD4- +AD4- +AD4- Signed-off-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-
+AD4- +AD4- +AD4- +AD4- ---
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Changes compared to v2:
+AD4- +AD4- +AD4- +AD4-    +ACo- Updated commit message with mention of of+AF8-phy+AF8-connect() instead of
+AD4- +AD4- +AD4- +AD4-      of+AF8-phy+AF8-attach().
+AD4- +AD4- +AD4- +AD4-    +ACo- Return ENODEV in case of of+AF8-phy+AF8-connect() failure
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Changes compared to v1:
+AD4- +AD4- +AD4- +AD4-    +ACo- Use IS+AF8-ERR+AF8-OR+AF8-NULL() instead of discrete checks for null and err
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4-    drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c +AHw- 7 +-+-+-+-+---
+AD4- +AD4- +AD4- +AD4-    1 file changed, 5 insertions(+-), 2 deletions(-)
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AD4- +AD4- b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AD4- +AD4- index 864b476..e2c9c86 100644
+AD4- +AD4- +AD4- +AD4- --- a/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AD4- +AD4- +-+-+- b/drivers/net/ethernet/stmicro/stmmac/stmmac+AF8-main.c
+AD4- +AD4- +AD4- +AD4- +AEAAQA- -837,9 +-837,12 +AEAAQA- static int stmmac+AF8-init+AF8-phy(struct net+AF8-device +ACo-dev)
+AD4- +AD4- +AD4- +AD4-    				     interface)+ADs-
+AD4- +AD4- +AD4- +AD4-    	+AH0-
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- -	if (IS+AF8-ERR(phydev)) +AHs-
+AD4- +AD4- +AD4- +AD4- +-	if (IS+AF8-ERR+AF8-OR+AF8-NULL(phydev)) +AHs-
+AD4- +AD4- +AD4- +AD4-    		pr+AF8-err(+ACIAJQ-s: Could not attach to PHY+AFw-n+ACI-, dev-+AD4-name)+ADs-
+AD4- +AD4- +AD4- +AD4- -		return PTR+AF8-ERR(phydev)+ADs-
+AD4- +AD4- +AD4- +AD4- +-		if (+ACE-phydev)
+AD4- +AD4- +AD4- +AD4- +-			return -ENODEV+ADs-
+AD4- +AD4- +AD4- +AD4- +-		else
+AD4- +AD4- +AD4- +AD4- +-			return PTR+AF8-ERR(phydev)+ADs-
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4-      Don't need +ACo-else+ACo- after +ACo-return+ACo- and scripts/checkpatch.pl should have
+AD4- +AD4- +AD4- complained about that.
+AD4- +AD4- 
+AD4- +AD4- ./scripts/checkpatch.pl 0001-stmmac-fix-check-for-phydev-being-open.patch
+AD4- +AD4- total: 0 errors, 0 warnings, 0 checks, 14 lines checked
+AD4- 
+AD4-     Hm... I bet I saw such warning from checkpatch.pl recently (it was a false 
+AD4- positive though, so maybe the check was removed recently, not sure). Your 
+AD4- patch is clean indeed, however my comment is still valid.

Ok, let me send another respin then.

-Alexey