From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/5] ISDN-Gigaset: Use kmalloc_array() in two functions
Date: Wed, 28 Sep 2016 13:37:15 +0200
Message-ID: <1475062635.16606.27.camel@tiscali.nl>
References: <566ABCD9.1060404@users.sourceforge.net>
         <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
         <4fb300f1-ff02-7983-464f-fcbca5919dac@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <4fb300f1-ff02-7983-464f-fcbca5919dac@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-26 at 17:38 +0200, SF Markus Elfring wrote:
> * Multiplications for the size determination of memory allocations
>   indicated that array data structures should be processed.
>   Thus use the corresponding function "kmalloc_array".

Was the current code incorrect? What makes kmalloc_array() better? None
of this is obvious to me.

I'm not going to change code just because some checker suggests to do
so.

>   This issue was detected by using the Coccinelle software.

So? And which coccinelle script was actually used? I couldn't spot a
coccinelle script doing that in the current tree.

> * Replace the specification of a data structure by a pointer dereference
>   to make the corresponding size determination a bit safer according to
>   the Linux coding style convention.

I'm not happy with you mixing this with the above, less trivial,
change.

> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -709,8 +709,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>  
>  	cs->mode = M_UNKNOWN;
>  	cs->mstate = MS_UNINITIALIZED;
> -

Unrelated whitespace change.

> -	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
> +	cs->bcs = kmalloc_array(channels, sizeof(*cs->bcs), GFP_KERNEL);

For the record: "channels" is basically hardcoded in the three gigaset
hardware drivers.

>  	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
>  	if (!cs->bcs || !cs->inbuf) {
>  		pr_err("out of memory\n");
> @@ -1089,8 +1088,7 @@ struct gigaset_driver
> *gigaset_initdriver(unsigned minor, unsigned minors,
>  	drv->ops = ops;
>  	drv->owner = owner;
>  	INIT_LIST_HEAD(&drv->list);
> -

Again unrelated whitespace change.

> -	drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL);
> +	drv->cs = kmalloc_array(minors, sizeof(*drv->cs), GFP_KERNEL);

For "minors" the same holds as for "channels", above.

And you snuck in a parentheses change. That should have probably been
merged with 5/5.

>  	if (!drv->cs)
>  		goto error;


Paul Bolle
