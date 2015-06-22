From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] stmmac: explicitly zero des0 & des1 on init
Date: Mon, 22 Jun 2015 06:43:15 +0000
Message-ID: <1434955394.4269.6.camel@synopsys.com>
References: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
	 <20150621.092948.394430183523491972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150621.092948.394430183523491972.davem@davemloft.net>
Content-Language: en-US
Content-ID: <823C88D46E9C524E8CAAE30336E09FF9@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sun, 2015-06-21 at 09:29 -0700, David Miller wrote:
+AD4- From: Alexey Brodkin +ADw-Alexey.Brodkin+AEA-synopsys.com+AD4-
+AD4- Date: Tue, 16 Jun 2015 20:40:41 +-0300
+AD4- 
+AD4- +AD4- Current implementtion of descriptor init procedure only takes care 
+AD4- +AD4- about
+AD4- +AD4- ownership flag. While it is perfectly possible to have underlying 
+AD4- +AD4- memory
+AD4- +AD4- filled with garbage on boot or driver installation.
+AD4- +AD4- 
+AD4- +AD4- And randomly set flags in non-zeroed des0 and des1 fields may lead 
+AD4- +AD4- to
+AD4- +AD4- unpredictable behavior of the GMAC DMA block.
+AD4- +AD4- 
+AD4- +AD4- Solution to this problem is as simple as explicit zeroing of both 
+AD4- +AD4- des0
+AD4- +AD4- and des1 fields of all buffer descriptors.
+AD4- +AD4- 
+AD4- +AD4- Signed-off-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-
+AD4- 
+AD4- If you need the memory zero initialized, use dma+AF8-zalloc+AF8-coherent().

Indeed usage of dma+AF8-zalloc+AF8-coherent() will resolve observed issue.
But since buffer descriptors are reused extensively I would say that
explicit zeroing of fields with flags is useful. Probably I need to add
this clarification in commit message.

And then if we do that explicit zeroing of flags and other fields which
hold data size and addresses of data buffer and the next descriptor in
chain are all get set later we may not care about allocation of zeroed
memory.

-Alexey--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
Please read the FAQ at  http://www.tux.org/lkml/
