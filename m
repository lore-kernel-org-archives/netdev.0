From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: [PATCH v2 7/8] net/macb: fix the peripheral version test
Date: Tue, 31 Mar 2015 15:08:19 +0000
Message-ID: <fca6d00c-5a4f-403b-ba18-bc08fefea121@BN1BFFO11FD016.protection.gbl>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
 <1427806926-18887-8-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Boris BREZILLON <boris.brezillon@free-electrons.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>,
 Michal Simek <michals@xilinx.com>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1427806926-18887-8-git-send-email-nicolas.ferre@atmel.com>
Content-Language: en-US
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



> -----Original Message-----
> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
> Sent: Tuesday, March 31, 2015 6:32 PM
> To: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org; David S.
> Miller
> Cc: linux-kernel@vger.kernel.org; Boris BREZILLON; Cyrille Pitchen; Alexandre
> Belloni; Michal Simek; Punnaiah Choudary Kalluri; Nicolas Ferre;
> stable@vger.kernel.org
> Subject: [PATCH v2 7/8] net/macb: fix the peripheral version test
>
> We currently need two checks of the peripheral version in MACB_MID
> register.
> One of them got out of sync after modification by 8a013a9c71b2 (net: macb:
> Include multi queue support for xilinx ZynqMP ethernet version).
> Fix this in macb_configure_caps() so that xilinx ZynqMP will be considered
> as a GEM flavor.
>
> Fixes: 8a013a9c71b2 ("net: macb: Include multi queue support for xilinx
> ZynqMP
> ethernet version")
>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
   Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

Thanks for the patch. We have this change in our tree but somehow missed while sending
this patch to mainline.

Regards,
Punnaiah
> Cc: Michal Simek <michal.simek@xilinx.com>
> Cc: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Cc: <stable@vger.kernel.org> #4.0 (if it doesn't make it for -final)
> ---
>
> Changes in v2:
> - fix peripheral version test
>
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c
> b/drivers/net/ethernet/cadence/macb.c
> index babe972a7c32..4412895cf4a8 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2139,7 +2139,7 @@ static void macb_configure_caps(struct macb *bp,
> const struct macb_config *dt_co
>       if (dt_conf)
>               bp->caps = dt_conf->caps;
>
> -     if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2)
> +     if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) >= 0x2)
>               bp->caps |= MACB_CAPS_MACB_IS_GEM;
>
>       if (macb_is_gem(bp)) {
> --
> 2.1.3



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
