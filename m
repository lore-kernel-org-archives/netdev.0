From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: rsi: fix integer overflow warning
Date: Fri, 13 Oct 2017 10:00:59 +0000 (UTC)
Message-ID: <20171013100100.B7A2F605A5@smtp.codeaurora.org>
References: <20171005120547.328687-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Prameela Rani Garnepudi <prameela.j04cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Amitkumar Karwar <amit.karwar-MngUzFJYhy7c8hPZMNZi9dBPR1lH4CV8@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Pavani Muthyala <pavani.muthyala-MngUzFJYhy7c8hPZMNZi9dBPR1lH4CV8@public.gmane.org>,
        Karun Eagalapati <karun256-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171005120547.328687-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:

> gcc produces a harmless warning about a recently introduced
> signed integer overflow:
> 
> drivers/net/wireless/rsi/rsi_91x_hal.c: In function 'rsi_prepare_mgmt_desc':
> include/uapi/linux/swab.h:13:15: error: integer overflow in expression [-Werror=overflow]
>   (((__u16)(x) & (__u16)0x00ffU) << 8) |   \
>    ~~~~~~~~~~~~^~~~~~~~~~~~~~~~~
> include/uapi/linux/swab.h:104:2: note: in expansion of macro '___constant_swab16'
>   ___constant_swab16(x) :   \
>   ^~~~~~~~~~~~~~~~~~
> include/uapi/linux/byteorder/big_endian.h:34:43: note: in expansion of macro '__swab16'
>  #define __cpu_to_le16(x) ((__force __le16)__swab16((x)))
>                                            ^~~~~~~~
> include/linux/byteorder/generic.h:89:21: note: in expansion of macro '__cpu_to_le16'
>  #define cpu_to_le16 __cpu_to_le16
>                      ^~~~~~~~~~~~~
> drivers/net/wireless/rsi/rsi_91x_hal.c:136:3: note: in expansion of macro 'cpu_to_le16'
>    cpu_to_le16((tx_params->vap_id << RSI_DESC_VAP_ID_OFST) &
>    ^~~~~~~~~~~
> 
> The problem is that the 'mask' value is a signed integer that gets
> turned into a negative number when truncated to 16 bits. Making it
> an unsigned constant avoids this.
> 
> Fixes: eac4eed3224b ("rsi: tx and rx path enhancements for p2p mode")
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

a39644b235c1 rsi: fix integer overflow warning

-- 
https://patchwork.kernel.org/patch/9986961/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
