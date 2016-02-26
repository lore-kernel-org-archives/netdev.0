From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: ezchip: adapt driver to little endian architecture
Date: Fri, 26 Feb 2016 21:12:58 +0100
Message-ID: <2727618.vosfDbrtXA@wuerfel>
References: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>
To: Lada Trimasova <Lada.Trimasova@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 26 February 2016 22:05:09 Lada Trimasova wrote:
> 
> @@ -75,6 +86,7 @@ struct nps_enet_rx_ctl {
>                  * nr:  Length in bytes of Rx frame loaded by MAC to Rx buffer
>                  */
>                 struct {
> +#ifdef CONFIG_CPU_BIG_ENDIAN
>                         u32
>                         __reserved_1:16,
>                         cr:1,
> @@ -82,6 +94,15 @@ struct nps_enet_rx_ctl {
>                         crc:1,
>                         __reserved_2:2,
>                         nr:11;
> +#else
> +                       u32
> +                       nr:11,
> +                       __reserved_2:2,
> +                       crc:1,
> +                       er:1,
> +                       cr:1,
> +                       __reserved_1:16;
> +#endif
>                 };

A nicer way to do this would be to remove all the bitfields
and use named constants for accessing the fields insode of
a u32 or u64 variable.

The order of the bits in a bit field is implementation specific
and your method might not work on all architectures. Even if the
driver is only meant to run on a single CPU architecture, it's
always better to write portable code.

	Arnd
