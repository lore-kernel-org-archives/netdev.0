From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 1/3] bnxt_en: include bnxt_vfr.c code under
 CONFIG_BNXT_SRIOV switch
Date: Tue, 25 Jul 2017 09:34:13 -0700
Message-ID: <CACKFLin8V4x4SqEi18Z3_aDDA5ZOL+wtfFxQwOOtjNNnvQXMkg@mail.gmail.com>
References: <20170725104933.9633-1-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:38185 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752405AbdGYQeO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 12:34:14 -0400
Received: by mail-qt0-f178.google.com with SMTP id t37so36157525qtg.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 09:34:14 -0700 (PDT)
In-Reply-To: <20170725104933.9633-1-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 3:49 AM, Sathya Perla <sathya.perla@broadcom.com> wrote:
> This fixes build error when CONFIG_BNXT_SRIOV is switched off:
>>> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:165:16: error: 'struct
>>> bnxt' has no member named 'sriov_lock'
>
> Reported-by: kbuild test robot <lkp@intel.com>
> Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
> index 83478e9..86850ae 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
> @@ -16,6 +16,8 @@
>  #include "bnxt.h"
>  #include "bnxt_vfr.h"
>
> +#ifdef CONFIG_BNXT_SRIOV
> +
>  #define CFA_HANDLE_INVALID             0xffff
>  #define VF_IDX_INVALID                 0xffff
>
> @@ -487,3 +489,5 @@ void bnxt_dl_unregister(struct bnxt *bp)
>         devlink_unregister(dl);
>         devlink_free(dl);
>  }
> +
> +#endif /* CONFIG_BNXT_SRIOV */

This won't work.  It will cause undefined symbols if CONFIG_BNXT_SRIOV
is not defined.  I will fix everything up and resend all 3 patches.
