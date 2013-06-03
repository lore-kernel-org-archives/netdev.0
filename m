From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] include/linux/skbuff.h: using '(u16) ~0U' instead of '~0U'
Date: Mon, 3 Jun 2013 14:34:42 +0300
Message-ID: <CAHp75VdSFRO2T_2Z1cVw_2Frk5MNLUBKd+p8S1sw_MBM+pyu=g@mail.gmail.com>
References: <51A6EBC5.7040601@asianux.com>
	<CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com>
	<51AC60AA.8010107@asianux.com>
	<CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com>
	<51AC7546.4010002@asianux.com>
	<51AC7CD4.2060801@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	Mel Gorman <mgorman@suse.de>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51AC7CD4.2060801@asianux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 3, 2013 at 2:24 PM, Chen Gang <gang.chen@asianux.com> wrote:
>
> Both 'transport_header' and 'mac_header' are u16, which are never equal
> to '~0U'.
>
> So need use '(u16) ~0U' instead of '~0U'.
>
> The related warning (with EXTRA_CFLAGS=-W ARCH=m68k for allmodconfig)
>   include/linux/skbuff.h:1587:2: warning: comparison is always true due to limited range of data type [-Wtype-limits]
>   ...
>
> Use meaningful macro instead of hard code number, and better to
> initialize 'skb->transport_header' in __alloc_skb_head(), too.

Looks okay. Couple of questions below.

> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -40,6 +40,8 @@
>  #define CHECKSUM_COMPLETE 2
>  #define CHECKSUM_PARTIAL 3
>
> +#define SKB_HEADER_UNSET_16    ((unsigned short) ~0U)

Isn't better to use the same type as used in the structure description?

> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -200,7 +200,8 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
>         atomic_set(&skb->users, 1);
>
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> -       skb->mac_header = (__u16) ~0U;
> +       skb->mac_header = SKB_HEADER_UNSET_16;
> +       skb->transport_header = SKB_HEADER_UNSET_16;

Is it correct to assign transport_header here as well?

--
With Best Regards,
Andy Shevchenko
