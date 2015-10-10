From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mISDN: use kstrdup() in dsp_pipeline_build
Date: Sat, 10 Oct 2015 12:22:10 -0700
Message-ID: <1444504930.8012.19.camel@perches.com>
References: <1efbeaf13aca3797e7d7f899ca00b27e37bbde9d.1444498002.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1efbeaf13aca3797e7d7f899ca00b27e37bbde9d.1444498002.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-10 at 02:32 -0700, Geliang Tang wrote:
> Use kstrdup instead of strlen-kmalloc-strcpy.

Not the same code.

Instead of returning early, a 0 length string will
now set pipeline->inuse to 0.

Maybe that's OK, but you should state why in the
commit log.

> diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
[]
> @@ -250,14 +250,9 @@ int dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg)
>  	if (!cfg)
>  		return 0;
>  
> -	len = strlen(cfg);
> -	if (!len)
> -		return 0;
> -
> -	dup = kmalloc(len + 1, GFP_ATOMIC);
> +	dup = kstrdup(cfg, GFP_ATOMIC);
>  	if (!dup)
>  		return 0;
> -	strcpy(dup, cfg);
>  	while ((tok = strsep(&dup, "|"))) {
>  		if (!strlen(tok))
>  			continue;
