From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [Patch] ariadne: fix possible null dereference
Date: Fri, 4 Mar 2011 10:31:21 -0800
Message-ID: <20110304103121.81a2364b.rdunlap@xenotime.net>
References: <20110304174625.GA31042@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: j223yang@asset.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110304174625.GA31042@asset.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2011 12:46:26 -0500 j223yang@asset.uwaterloo.ca wrote:

> This patch fixes bugzilla #13853:
> https://bugzilla.kernel.org/show_bug.cgi?id=13853
> 
> The patch removes dereference of 'dev' after testing for NULL.
> The source code ariadne.c uses spaces instead of tabs, so the patch
> uses spaces too.

Sorry for the confusion here, but (while I agree with the fix in this
patch), this patch still does not apply cleanly.

If a line in the source code file uses spaces, then use spaces.
If a line in the source code file uses tabs, then use tabs.

You cannot exchange one for the other in your generated patch.
Using 'diff' creates the patch correctly, so I guess that your patch
generation tool still needs some work.

Please take your patch and test applying it:

> cd linux-2.6.38-rc7
> patch -p1 --dry-run < ~/tmp/ariadne.patch
patching file drivers/net/ariadne.c
Hunk #2 FAILED at 430.
1 out of 2 hunks FAILED -- saving rejects to file drivers/net/ariadne.c.rej


> Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
> ---
>  drivers/net/ariadne.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
> --- a/drivers/net/ariadne.c
> +++ b/drivers/net/ariadne.c
> @@ -420,7 +420,7 @@ static inline void ariadne_reset(struct
>  static irqreturn_t ariadne_interrupt(int irq, void *data)
>  {
>      struct net_device *dev = (struct net_device *)data;
> -    volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
> +    volatile struct Am79C960 *lance;
>      struct ariadne_private *priv;
>      int csr0, boguscnt;
>      int handled = 0;
> @@ -430,6 +430,7 @@ static irqreturn_t ariadne_interrupt(int
>         return IRQ_NONE;
>      }
> 
> +    lance = (struct Am79C960 *)dev->base_addr;
>      lance->RAP = CSR0;                 /* PCnet-ISA Controller Status */
> 
>      if (!(lance->RDP & INTR))          /* Check if any interrupt has been */
> 
> --

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
