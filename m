From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 1/4] net: ethernet: ti: cpdma: fix lockup in
 cpdma_ctlr_destroy()
Date: Fri, 29 Jul 2016 13:46:36 +0530
Message-ID: <c33aa3f3-15e3-3a48-8a48-84b9d1e55ca5@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
 <20160728175037.22053-2-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728175037.22053-2-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 July 2016 11:20 PM, Grygorii Strashko wrote:
> Fix deadlock in cpdma_ctlr_destroy() which is triggered now on
> cpsw module removal:
>  cpsw_remove()
>  - cpdma_ctlr_destroy()
>    - spin_lock_irqsave(&ctlr->lock, flags)
>    - cpdma_ctlr_stop()
>      - spin_lock_irqsave(&ctlr->lock, flags);
>    - cpdma_chan_destroy()
>      - spin_lock_irqsave(&ctlr->lock, flags);
> 
> The issue has not been observed before because CPDMA channels have
> been destroyed manually by CPSW until commit d941ebe88a41 ("net:
> ethernet: ti: cpsw: use destroy ctlr to destroy channels") was merged.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
