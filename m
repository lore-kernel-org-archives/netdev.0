From: Pramod Gurav <pramod.gurav.etc@gmail.com>
Subject: Re: [PATCH v2] ssb: Fix Sparse error in main
Date: Tue, 28 Oct 2014 22:03:02 +0530
Message-ID: <CAMf-jSk4GH=8+Cpk4dCzUhbwoKxMOsJPPrURP5-ktAvqXfhsjw@mail.gmail.com>
References: <1412184482-2603-1-git-send-email-pramod.gurav@smartplayin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michael Buesch <m@bues.ch>, netdev@vger.kernel.org
To: Pramod Gurav <pramod.gurav@smartplayin.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412184482-2603-1-git-send-email-pramod.gurav@smartplayin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael had suggested to do away with this function if not being used.
Good to go?

Michale can you provide acked-by?

On Wed, Oct 1, 2014 at 10:58 PM, Pramod Gurav
<pramod.gurav@smartplayin.com> wrote:
> This change fixes below sparse error:
> drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
> was not declared. Should it be static?
>
> Cc: Michael Buesch <m@bues.ch>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
> ---
> Changes since v1:
> Removed the function as it is not called anywhere in the kernel
> as per suggestion from Michael Buesch.
>
>  drivers/ssb/main.c | 19 -------------------
>  1 file changed, 19 deletions(-)
>
> diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> index 2fead38..1e180c4 100644
> --- a/drivers/ssb/main.c
> +++ b/drivers/ssb/main.c
> @@ -90,25 +90,6 @@ found:
>  }
>  #endif /* CONFIG_SSB_PCMCIAHOST */
>
> -#ifdef CONFIG_SSB_SDIOHOST
> -struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func)
> -{
> -       struct ssb_bus *bus;
> -
> -       ssb_buses_lock();
> -       list_for_each_entry(bus, &buses, list) {
> -               if (bus->bustype == SSB_BUSTYPE_SDIO &&
> -                   bus->host_sdio == func)
> -                       goto found;
> -       }
> -       bus = NULL;
> -found:
> -       ssb_buses_unlock();
> -
> -       return bus;
> -}
> -#endif /* CONFIG_SSB_SDIOHOST */
> -
>  int ssb_for_each_bus_call(unsigned long data,
>                           int (*func)(struct ssb_bus *bus, unsigned long data))
>  {
> --
> 1.8.3.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Thanks and Regards
Pramod
