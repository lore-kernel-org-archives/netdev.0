From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] net: bnxt: always return values from
 _bnxt_get_max_rings
Date: Tue, 12 Jan 2016 09:55:43 -0800
Message-ID: <1452621343.13732.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <4309490.qRrvvx0n1Q@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Jeffrey Huang <huangjw@broadcom.com>,
	<linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4309490.qRrvvx0n1Q@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 16:05 +0100, Arnd Bergmann wrote:
> Newly added code in the bnxt driver uses a couple of variables that
> are never initialized when CONFIG_BNXT_SRIOV is not set, and gcc
> correctly warns about that:
> 
> In file included from include/linux/list.h:8:0,
>                  from include/linux/module.h:9,
>                  from drivers/net/ethernet/broadcom/bnxt/bnxt.c:10: 
> drivers/net/ethernet/broadcom/bnxt/bnxt.c: In function 'bnxt_get_max_rings':
> include/linux/kernel.h:794:26: warning: 'cp' may be used uninitialized in this function [-Wmaybe-uninitialized]
> include/linux/kernel.h:794:26: warning: 'tx' may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/ethernet/broadcom/bnxt/bnxt.c:5730:11: warning: 'rx' may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/ethernet/broadcom/bnxt/bnxt.c:5736:6: note: 'rx' was declared here
> 
> This changes the condition so that we fall back to using the PF
> data if VF is not available, and always initialize the variables
> to something useful.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 6e6c5a57fbe1 ("bnxt_en: Modify bnxt_get_max_rings() to support
> shared or non shared rings.")
> ---
> This is the fix that made most sense to me, but that doesn't mean it's
> the right thing to do for this driver, so please check carefully
> whether falling back to PF is actually the correct behavior.
> 
> I'm assuming that BNXT_PF(bp) is meant to always be true if
> CONFIG_BNXT_SRIOV
> is disabled, but I have not verified if this is guaranteed. 

The assumption is correct.  Patch looks good.  Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>
