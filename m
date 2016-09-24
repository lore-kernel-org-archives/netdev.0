From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/6] isdn/hisax: add function declarations
Date: Sat, 24 Sep 2016 10:47:25 +0200
Message-ID: <19682404.Wm2acsDIf0@wuerfel>
References: <1474694507-7379-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: isdn@linux-pingi.de, linux-kernel.bfrz@manchmal.in-ulm.de,
        davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474694507-7379-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 24, 2016 1:21:47 PM CEST Baoyou Xie wrote:
> --- a/drivers/isdn/hisax/config.c
> +++ b/drivers/isdn/hisax/config.c
> @@ -460,42 +460,14 @@ __setup("hisax=", HiSax_setup);
>  extern int setup_teles0(struct IsdnCard *card);
>  #endif
>  
> -#if CARD_TELES3
> -extern int setup_teles3(struct IsdnCard *card);
> -#endif
...
> -#if CARD_TELESPCI
> -extern int setup_telespci(struct IsdnCard *card);
> -#endif
> -
>  #if CARD_AVM_A1
>  extern int setup_avm_a1(struct IsdnCard *card);
>  #endif

It seems odd that you remove some but not all declarations
here. Please do all of them at once.

> @@ -1350,3 +1350,63 @@ static inline struct pci_dev *hisax_find_pci_device(unsigned int vendor,
>  }
>  
>  #endif
> +
> +#if CARD_TELES3
> +int setup_teles3(struct IsdnCard *card);
> +#endif
> +
> +#if CARD_TELESPCI
> +int setup_telespci(struct IsdnCard *card);
> +#endif
> +

When you add the declarations here, just leave out the #if guards,
and put all the declarations here unconditionally, as we normally
do in the kernel.

	Arnd
