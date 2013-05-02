From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] VSOCK: Drop bogus __init annotation from vsock_init_tables()
Date: Thu, 2 May 2013 08:54:21 +0200
Message-ID: <CAMuHMdUs-3MwDi-GFE8-zuSarvYsULjPU27CkNAt6fkiu7b21A@mail.gmail.com>
References: <1366796455-2520-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	stable@vger.kernel.org
To: Andy King <acking@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:38024 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab3EBGyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 02:54:23 -0400
In-Reply-To: <1366796455-2520-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCing stable, as this patch didn't make it in v3.9.
Mainline commit ID is 22ee3b57c3ff71772b0c4178404b04f5df78d501.

On Wed, Apr 24, 2013 at 11:40 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> If gcc (e.g. 4.1.2) decides not to inline vsock_init_tables(), this will
> cause a section mismatch:
>
> WARNING: net/vmw_vsock/vsock.o(.text+0x1bc): Section mismatch in reference from the function __vsock_core_init() to the function .init.text:vsock_init_tables()
> The function __vsock_core_init() references
> the function __init vsock_init_tables().
> This is often because __vsock_core_init lacks a __init
> annotation or the annotation of vsock_init_tables is wrong.
>
> This may cause crashes if VSOCKETS=y and VMWARE_VMCI_VSOCKETS=m.
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  net/vmw_vsock/af_vsock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index 7f93e2a..2e330e8 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -165,7 +165,7 @@ static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
>  static struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
>  static DEFINE_SPINLOCK(vsock_table_lock);
>
> -static __init void vsock_init_tables(void)
> +static void vsock_init_tables(void)
>  {
>         int i;
>
> --
> 1.7.0.4

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
