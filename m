From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] connector: Delete an error message for a failed memory
 allocation in cn_queue_alloc_callback_entry()
Date: Sun, 27 Aug 2017 23:16:06 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F0779689E@ORSMSX103.amr.corp.intel.com>
References: <7b206228-b3e9-5cb9-873c-75b5d8aae23b@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/17 3:26 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 27 Aug 2017 21:18:37 +0200
> 
> Omit an extra message for a memory allocation failure in this function.
> 
> This issue was detected by using the Coccinelle software.

Did coccinelle trip on the message or the fact you weren't returning NULL?

> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   drivers/connector/cn_queue.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
> index 1f8bf054d11c..e4f31d679f02 100644
> --- a/drivers/connector/cn_queue.c
> +++ b/drivers/connector/cn_queue.c
> @@ -40,10 +40,8 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
>   	struct cn_callback_entry *cbq;
>   
>   	cbq = kzalloc(sizeof(*cbq), GFP_KERNEL);
> -	if (!cbq) {
> -		pr_err("Failed to create new callback queue.\n");
> +	if (!cbq)
>   		return NULL;
> -	}

Wny not:

	if (!cbq) {
		pr_err("Failed to create new callback queue.\n");
+		return NULL;
	}

>   
>   	atomic_set(&cbq->refcnt, 1);
>   
> 
