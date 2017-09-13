From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 10/10] fs:btrfs: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 17:13:08 +0200
Message-ID: <20170913151308.GL29043@twin.jikos.cz>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
 <1505287939-14106-10-git-send-email-allen.lkml@gmail.com>
Reply-To: dsterba@suse.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
        linux-crypto@vger.kernel.org, dri-devel@lists.freedesktop.org,
        MPT-FusionLinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, megaraidlinux.pdl@broadcom.com,
        target-devel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-btrfs@vger.kernel.org
To: Allen Pais <allen.lkml@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1505287939-14106-10-git-send-email-allen.lkml@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 13, 2017 at 01:02:19PM +0530, Allen Pais wrote:
> Signed-off-by: Allen Pais <allen.lkml@gmail.com>
> ---
>  fs/btrfs/check-integrity.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
> index 7d5a9b5..efa4c23 100644
> --- a/fs/btrfs/check-integrity.c
> +++ b/fs/btrfs/check-integrity.c
> @@ -2913,7 +2913,7 @@ int btrfsic_mount(struct btrfs_fs_info *fs_info,
>  	state = kvzalloc(sizeof(*state), GFP_KERNEL);
>  	if (!state) {
>  		pr_info("btrfs check-integrity: allocation failed!\n");
> -		return -1;
> +		return -ENOMEM;

Makes sense, also please fix the -1 a few lines below that also result
from failed memory allocation, indirectly from btrfsic_dev_state_alloc().

>  	}
>  
>  	if (!btrfsic_is_initialized) {
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
