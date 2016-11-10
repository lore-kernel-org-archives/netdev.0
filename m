From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next resend 10/13] debugfs: constify argument to
 debugfs_real_fops()
Date: Thu, 10 Nov 2016 15:25:59 +0100
Message-ID: <20161110142559.GA15902@kroah.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
 <1478193129-23476-11-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolai Stange <nicstange@gmail.com>,
        Christian Lamparter <chunkeey@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478193129-23476-11-git-send-email-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 03, 2016 at 05:12:06PM +0000, Jakub Kicinski wrote:
> seq_file users can only access const version of file pointer,
> because the ->file member of struct seq_operations is marked
> as such.  Make parameter to debugfs_real_fops() const.
> 
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> CC: Nicolai Stange <nicstange@gmail.com>
> CC: Christian Lamparter <chunkeey@gmail.com>
> CC: LKML <linux-kernel@vger.kernel.org>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/debugfs.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
> index 4d3f0d1aec73..bf1907d96097 100644
> --- a/include/linux/debugfs.h
> +++ b/include/linux/debugfs.h
> @@ -52,7 +52,8 @@ struct debugfs_regset32 {
>   * Must only be called under the protection established by
>   * debugfs_use_file_start().
>   */
> -static inline const struct file_operations *debugfs_real_fops(struct file *filp)
> +static inline const struct file_operations *
> +debugfs_real_fops(const struct file *filp)

Ick.  Tell me that looks better :(

Please just don't wrap things like that, just make it go longer than 80
columns, I can handle the complaints...

thanks,

greg k-h
