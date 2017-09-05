From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Delete an error message for a failed memory allocation in cn_queue_alloc_callback_entry()
Date: Tue, 05 Sep 2017 16:10:58 +0300
Message-ID: <109501504617058@web52g.yandex.ru>
References: <7b206228-b3e9-5cb9-873c-75b5d8aae23b@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <7b206228-b3e9-5cb9-873c-75b5d8aae23b@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone

27.08.2017, 22:25, "SF Markus Elfring" <elfring@users.sourceforge.net>:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 27 Aug 2017 21:18:37 +0200
>
> Omit an extra message for a memory allocation failure in this function.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Looks good to me, thanks Markus.
There is virtually zero useful information in this print if we are in the situation, when kernel can not allocate
a few bytes to run connector queue.

Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

kernel-janitors@ please queue this patch up

> ---
>  drivers/connector/cn_queue.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
> index 1f8bf054d11c..e4f31d679f02 100644
> --- a/drivers/connector/cn_queue.c
> +++ b/drivers/connector/cn_queue.c
> @@ -40,10 +40,8 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
>          struct cn_callback_entry *cbq;
>
>          cbq = kzalloc(sizeof(*cbq), GFP_KERNEL);
> - if (!cbq) {
> - pr_err("Failed to create new callback queue.\n");
> + if (!cbq)
>                  return NULL;
> - }
>
>          atomic_set(&cbq->refcnt, 1);
>
> --
> 2.14.1
