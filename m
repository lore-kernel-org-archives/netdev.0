From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: wireless: ath: ath9k: constify ath_bus_ops structure
Date: Thu, 1 Dec 2016 12:18:07 +0100
Message-ID: <3afc412c6871406cb9f952c6a6f5c038@euamsexm01a.eu.qualcomm.com>
References: <1480266206-26732-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <ath9k-devel@qca.qualcomm.com>,
        <kvalo@codeaurora.org>, <linux-wireless@vger.kernel.org>,
        <ath9k-devel@lists.ath9k.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480266206-26732-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:
> Declare the structure ath_bus_ops as const as it is only passed as an
> argument to the function ath9k_init_device. This argument is of type
> const struct ath_bus_ops *, so ath_bus_ops structures with this property
> can be declared as const.
> Done using Coccinelle:
> @r1 disable optional_qualifier @
> identifier i;
> position p;
> @@
> static struct ath_bus_ops i@p = {...};
> 
> @ok1@
> identifier r1.i;
> position p;
> expression e1,e2;
> @@
> ath9k_init_device(e1,e2,&i@p)
> 
> @bad@
> position p!={r1.p,ok1.p};
> identifier r1.i;
> @@
> i@p
> 
> @depends on !bad disable optional_qualifier@
> identifier r1.i;
> @@
> static
> +const
> struct ath_bus_ops i={...};
> 
> @depends on !bad disable optional_qualifier@
> identifier r1.i;
> @@
> +const
> struct ath_bus_ops i;
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>    1295	    232	      0	   1527	    5f7	ath/ath9k/ahb.o
> 
> File size after:
>    text	   data	    bss	    dec	    hex	filename
>    1359	    176	      0	   1535	    5ff	ath/ath9k/ahb.o
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to ath-next branch of ath.git, thanks.

8ca5a6078d6d ath9k: constify ath_bus_ops structure

-- 
https://patchwork.kernel.org/patch/9448851/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
