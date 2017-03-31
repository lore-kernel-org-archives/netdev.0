From: Steve deRosier <derosier@gmail.com>
Subject: Re: [PATCH] ath6kl: Add __printf verification to ath6kl_dbg
Date: Fri, 31 Mar 2017 10:19:16 -0700
Message-ID: <CALLGbR+szcYFdbdh_0qBS4B_X6YQvU6CDFpR-XZvc7p3zA+ZdQ@mail.gmail.com>
References: <e4556e95a5935f591fdff67c6fb2f7ef5c7fd04f.1490914618.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35749 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933153AbdCaRTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 13:19:19 -0400
In-Reply-To: <e4556e95a5935f591fdff67c6fb2f7ef5c7fd04f.1490914618.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 3:57 PM, Joe Perches <joe@perches.com> wrote:
> Fix fallout too.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/ath/ath6kl/debug.h    | 2 ++
>  drivers/net/wireless/ath/ath6kl/htc_pipe.c | 2 +-
>  drivers/net/wireless/ath/ath6kl/wmi.c      | 2 +-
>  3 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
> index 0614393dd7ae..94297572914f 100644
> --- a/drivers/net/wireless/ath/ath6kl/debug.h
> +++ b/drivers/net/wireless/ath/ath6kl/debug.h
> @@ -63,6 +63,7 @@ int ath6kl_read_tgt_stats(struct ath6kl *ar, struct ath6kl_vif *vif);
>
>  #ifdef CONFIG_ATH6KL_DEBUG
>
> +__printf(2, 3)
>  void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...);
>  void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
>                      const char *msg, const char *prefix,
> @@ -83,6 +84,7 @@ int ath6kl_debug_init_fs(struct ath6kl *ar);
>  void ath6kl_debug_cleanup(struct ath6kl *ar);
>
>  #else
> +__printf(2, 3)
>  static inline void ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask,
>                               const char *fmt, ...)
>  {

My only question is why bother doing a format check on something
that's going to be compiled out anyway? I suppose the only harm is a
tiny extra bit of compile time due to the check and I'm sure that's
measured in micro-seconds on full development systems, but if we do it
everywhere those tiny bits of time would eventually add up.

Admittedly it's a comment that probably isn't worth redoing the commit
over.  I guess I'm bringing up the point more discuss the question:
"Should we add the printf format verification on the clauses that get
compiled out?"

So, it looks good to me as is, or if you feel like making the change
I'm suggesting, that's fine too.  And it builds and runs on my
platforms.

Reviewed-by: Steve deRosier <derosier@gmail.com>

- Steve
