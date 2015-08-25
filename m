From: Jiri Benc <jbenc@redhat.com>
Subject: Re: use after free again...
Date: Tue, 25 Aug 2015 18:09:47 +0200
Message-ID: <20150825180947.0e47ce32@griffin>
References: <CAHA+R7Mr03t5NQMhdeY0ygHM5+nzMecoQL7TFOMNmR1+OgCQ7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875AbbHYQJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 12:09:50 -0400
In-Reply-To: <CAHA+R7Mr03t5NQMhdeY0ygHM5+nzMecoQL7TFOMNmR1+OgCQ7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Aug 2015 23:02:02 -0700, Cong Wang wrote:
> Hi, Jiri,
> 
> In your commit 61adedf3e3f1d3f032c5a6a299978d91eff6d555 ("route: move
> lwtunnel state to dst_entry"), how the hell could the following piece
> be correct? :-/

It's not.

> I cooked a _quick_ patch to fix it. I can send it formally if it looks
> good to you, if not, feel free to send a better fix before me.
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 50dcdbb..477035e 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -262,11 +262,12 @@ again:
>         if (dst->dev)
>                 dev_put(dst->dev);
> 
> +       lwtstate_put(dst->lwtstate);
> +
>         if (dst->flags & DST_METADATA)
>                 kfree(dst);
>         else
>                 kmem_cache_free(dst->ops->kmem_cachep, dst);
> -       lwtstate_put(dst->lwtstate);
> 
>         dst = child;
>         if (dst) {

Looks good. You can add my
Acked-by: Jiri Benc <jbenc@redhat.com>
when you submit it.

Thanks a lot,

 Jiri

-- 
Jiri Benc
