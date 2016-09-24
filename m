From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/6] isdn/hisax: clean function declaration in hscx.c up
Date: Sat, 24 Sep 2016 10:45:14 +0200
Message-ID: <1876960.mYVMvaW4Lo@wuerfel>
References: <1474694662-7527-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474694662-7527-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 24, 2016 1:24:22 PM CEST Baoyou Xie wrote:
>  }
>  
> -extern int open_hscxstate(struct IsdnCardState *cs, struct BCState *bcs);
>  extern void modehscx(struct BCState *bcs, int mode, int bc);
>  extern void hscx_l2l1(struct PStack *st, int pr, void *arg);
>  

The change makes sense, but I would remove the other two declarations
as well, as extern declarations don't belong into .c files.

As far as I can tell, modehscx() already has a declaration in hscx.h,
while hscx_l2l1() doesn't, and the declaration here should be
moved as well.

> diff --git a/drivers/isdn/hisax/hscx.h b/drivers/isdn/hisax/hscx.h
> index 1148b4b..fa7bf16 100644
> --- a/drivers/isdn/hisax/hscx.h
> +++ b/drivers/isdn/hisax/hscx.h
> @@ -39,3 +39,4 @@ extern void modehscx(struct BCState *bcs, int mode, int bc);
>  extern void clear_pending_hscx_ints(struct IsdnCardState *cs);
>  extern void inithscx(struct IsdnCardState *cs);
>  extern void inithscxisac(struct IsdnCardState *cs, int part);
> +int open_hscxstate(struct IsdnCardState *cs, struct BCState *bcs);

For consistency, I would add 'extern' here. We normally leave that out,
but I think if there are lots of declarations in a header file that all
have it, it's better if they are all the same.

	Arnd
