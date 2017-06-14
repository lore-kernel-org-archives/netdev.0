From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2][PATCH] ip: Remove unneed header
Date: Wed, 14 Jun 2017 10:04:35 -0700
Message-ID: <20170614100435.30df62d3@xeon-e3>
References: <1497242015-11611-1-git-send-email-changhyeok.bae@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Changhyeok Bae <changhyeok.bae@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35847 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdFNREr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:04:47 -0400
Received: by mail-pg0-f42.google.com with SMTP id a70so2813307pge.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:04:47 -0700 (PDT)
In-Reply-To: <1497242015-11611-1-git-send-email-changhyeok.bae@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jun 2017 04:33:35 +0000
Changhyeok Bae <changhyeok.bae@gmail.com> wrote:

> Fix redefinition of struct ethhdr with a suitably patched musl libc
> that suppresses the kernel if_ether.h.
>=20
> Signed-off-by: Changhyeok Bae <changhyeok.bae@gmail.com>
> ---
>  ip/iplink_bridge.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
> index cccdec1..f065b22 100644
> --- a/ip/iplink_bridge.c
> +++ b/ip/iplink_bridge.c
> @@ -13,7 +13,6 @@
>  #include <stdlib.h>
>  #include <string.h>
>  #include <netinet/in.h>
> -#include <netinet/ether.h>
>  #include <linux/if_link.h>
>  #include <linux/if_bridge.h>
>  #include <net/if.h>

Sorry, doing this causes:

iplink_bridge.c: In function =E2=80=98br_dump_bridge_id=E2=80=99:
iplink_bridge.c:77:2: warning: implicit declaration of function =E2=80=98et=
her_ntoa_r=E2=80=99 [-Wimplicit-function-declaration]
  ether_ntoa_r((const struct ether_addr *)id->addr, eaddr);
