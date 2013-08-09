From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 08:14:27 -0700
Message-ID: <1376061267.2087.91.camel@joe-AO722>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	 <20130808210918.GE5502@mwanda>
	 <20130808.142054.1541424422807503741.davem@davemloft.net>
	 <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com>
	 <1376015984.2087.31.camel@joe-AO722> <520457AD.9060508@gmail.com>
	 <1376016864.2087.34.camel@joe-AO722> <52045B31.9000002@gmail.com>
	 <1376018881.2087.48.camel@joe-AO722> <5204641C.3090905@gmail.com>
	 <CA+MoWDrsHf4NFE_iszymh6SaBfXsMybC194ZQaKgURmCFwiJRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gaurav <kumargauravgupta3@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <CA+MoWDrsHf4NFE_iszymh6SaBfXsMybC194ZQaKgURmCFwiJRQ@mail.gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-09 at 15:15 +0200, Peter Senna Tschudin wrote:
> Coccinelle (http://coccinelle.lip6.fr/) can help you in this task. The
> semantic patch below takes care of both cases for you:

Hi Peter & Kumar

Coccinelle (aka: spatch) is a good/great way to do this.

(btw Peter, your email was whitespace damaged)

Peter's useful conversion won't find/convert cases where
IRQF_DISABLED is used in a #define like:

> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
> []
> @@ -915,7 +915,7 @@ static int ks_net_open(struct net_device *netdev)
> []
> -#define        KS_INT_FLAGS    (IRQF_DISABLED|IRQF_TRIGGER_LOW)
> +#define        KS_INT_FLAGS    (IRQF_TRIGGER_LOW)

You'd still have to do those by hand.

Also, it's good to just do the direct conversions/renames
so that it's easy to verify just a single attribute has
been changed by the patches.

There are tools like Dan Carpenter's rename_review.pl
https://lkml.org/lkml/2011/7/19/196
that can help you verify the patches.

These patches will generate different objects than the
original codes.  Otherwise, it's good to make sure that for
whitespace only/style patches, the objects are unchanged.

Make the patch that removes the IRQF_DISABLED #define
last in the series and maybe do not even submit it until a
few weeks after all the other patches are accepted.

Lastly, it might also be good to reflow the modified code
to maximally fill to 80 columns where reasonable.  This can
both make the code a bit more human readable and reduce the
overall line count.

Just remember it's generally better to do any code reflow
in a separate patch.  To me the criteria for combining
is how large the rename patch is.  Smallish, ok to reflow,
largish, not ok.  Use your taste as appropriate.


