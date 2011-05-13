From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/9] iwlegacy: Silence DEBUG_STRICT_USER_COPY_CHECKS=y
 warning
Date: Fri, 13 May 2011 11:08:26 +0200
Message-ID: <20110513090825.GB2206@redhat.com>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
 <1305244212-19183-2-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305244212-19183-2-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 04:50:04PM -0700, Stephen Boyd wrote:
> Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
> warning:
> 
> In file included from arch/x86/include/asm/uaccess.h:573,
>                  from include/net/checksum.h:25,
>                  from include/linux/skbuff.h:28,
>                  from drivers/net/wireless/iwlegacy/iwl-4965-rs.c:28:
> In function 'copy_from_user',
>     inlined from 'iwl4965_rs_sta_dbgfs_scale_table_write' at
>     drivers/net/wireless/iwlegacy/iwl-4965-rs.c:2616:
> arch/x86/include/asm/uaccess_64.h:65:
> warning: call to 'copy_from_user_overflow' declared with
> attribute warning: copy_from_user() buffer size is not provably
> correct
> 
> presumably due to buf_size being signed causing GCC to fail to
> see that buf_size can't become negative.
> 
> Cc: Johannes Berg <johannes.berg@intel.com>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
> ---
>  drivers/net/wireless/iwlegacy/iwl-4965-rs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
> index 31ac672..cc4751c 100644
> --- a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
> +++ b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
> @@ -2604,7 +2604,7 @@ static ssize_t iwl4965_rs_sta_dbgfs_scale_table_write(struct file *file,
>  	struct iwl_lq_sta *lq_sta = file->private_data;
>  	struct iwl_priv *priv;
>  	char buf[64];
> -	int buf_size;
> +	size_t buf_size;

ACK, but we have more of that, perhaps you would like to fix them all.
If you don't want to, I'll do it. Note this can be easily done by:

sed -i 's/int buf_size;/size_t buf_size;/g' drivers/net/wireless/iwlegacy/*.[ch]

Stanislaw
