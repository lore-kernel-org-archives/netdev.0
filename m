From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: cosa: use memdup_user().
Date: Mon, 23 May 2016 14:02:32 -0700 (PDT)
Message-ID: <20160523.140232.31037641382794779.davem@davemloft.net>
References: <1463746806-23739-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463746806-23739-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Fri, 20 May 2016 17:50:06 +0530

> Use memdup_user to duplicate a memory region from user-space to
> kernel-space, instead of open coding using kmalloc & copy_from_user.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
> ---
>  drivers/net/wan/cosa.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
> index b87fe0a..fb37439 100644
> --- a/drivers/net/wan/cosa.c
> +++ b/drivers/net/wan/cosa.c
> @@ -876,15 +876,10 @@ static ssize_t cosa_write(struct file *file,
>  		count = COSA_MTU;
>  	
>  	/* Allocate the buffer */
> -	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
> -	if (kbuf == NULL) {
> +	kbuf = memdup_user(buf, count);

You're losing the GFP_DMA specification here, therefore this change
is not correct.
