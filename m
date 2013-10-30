From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch v2] libertas: potential oops in debugfs
Date: Wed, 30 Oct 2013 14:51:40 -0500
Message-ID: <1383162700.21123.11.camel@dcbw.foobar.com>
References: <20131030171251.GA4130@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131030171251.GA4130@longonot.mountain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-30 at 20:12 +0300, Dan Carpenter wrote:
> If we do a zero size allocation then it will oops.  Also we can't be
> sure the user passes us a NUL terminated string so I've added a
> terminator.
> 
> This code can only be triggered by root.
> 
> Reported-by: Nico Golde <nico@ngolde.de>
> Reported-by: Fabian Yamaguchi <fabs@goesec.de>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Dan Williams <dcbw@redhat.com>

> 
> diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
> index 668dd27..1917348 100644
> --- a/drivers/net/wireless/libertas/debugfs.c
> +++ b/drivers/net/wireless/libertas/debugfs.c
> @@ -913,7 +913,10 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
>  	char *p2;
>  	struct debug_data *d = f->private_data;
>  
> -	pdata = kmalloc(cnt, GFP_KERNEL);
> +	if (cnt == 0)
> +		return 0;
> +
> +	pdata = kmalloc(cnt + 1, GFP_KERNEL);
>  	if (pdata == NULL)
>  		return 0;
>  
> @@ -922,6 +925,7 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
>  		kfree(pdata);
>  		return 0;
>  	}
> +	pdata[cnt] = '\0';
>  
>  	p0 = pdata;
>  	for (i = 0; i < num_of_items; i++) {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
