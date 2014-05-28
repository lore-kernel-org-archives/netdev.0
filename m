From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] mvme147: use correct order of ram pages
Date: Wed, 28 May 2014 09:51:39 +0200
Message-ID: <CAMuHMdV-g35ijLgcE=sSM3eE+fCxC1WOiAX2PaWs0z4-+bDP+A@mail.gmail.com>
References: <1401250073-16603-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Linux/m68k" <linux-m68k@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Amos Kong <akong@redhat.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1401250073-16603-1-git-send-email-akong@redhat.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Amos,

On Wed, May 28, 2014 at 6:07 AM, Amos Kong <akong@redhat.com> wrote:
> 16K is 2^2 * PAGE_SIZE, so the page order should be 2, not 3.
>
> This patch uses get_order() to get correct order, and fixes
> one typo in comment.

Thanks for your patch!

> Signed-off-by: Amos Kong <akong@redhat.com>
> ---
> This patch wasn't built. Geert, can you help to test it?
> I don't know if it needs a head file by using get_order().

It builds fine. The get_order() is nicely expanded to "2" in the assembler
output.

Now, I'd like to get some feedback from the MVME hackers first.
Perhaps the comment was wrong?

> -/* We have 16834 bytes of RAM for the init block and buffers. This places
> +/* We have 16384 bytes of RAM for the init block and buffers. This places
>   * an upper limit on the number of buffers we can use. NetBSD uses 8 Rx
>   * buffers and 2 Tx buffers.
>   */
> +#define M147LANCE_RAM_SIZE   16384 /* 16K */
>  #define LANCE_LOG_TX_BUFFERS 1
>  #define LANCE_LOG_RX_BUFFERS 3

BTW,I also find it fishy why the driver uses only 1+3 buffers, since more
RAM is available.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
