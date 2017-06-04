From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: ensure jumbo_frm error return is
 correctly checked for -ve value
Date: Sun, 04 Jun 2017 19:58:15 -0400 (EDT)
Message-ID: <20170604.195815.1578427347580474114.davem@davemloft.net>
References: <20170602145827.21151-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170602145827.21151-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  2 Jun 2017 15:58:27 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The current comparison of entry < 0 will never be true since entry is an
> unsigned integer. Cast entry to an int to ensure -ve error return values
> from the call to jumbo_frm are correctly being caught.
> 
> Detected by CoverityScan, CID#1238760 ("Macro compares unsigned to 0")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Like others have suggested, probably making 'entry' signed is
a better fix.

I was initially worried that STMMAC_GET_ENTRY() might become
more expensive if it was implemented using '%' but it is using
'and' masking instead which doesn't have that kind of problem.
