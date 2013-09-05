From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 5 Sep 2013 21:25:20 +0200
Message-ID: <CAMuHMdVoESdkxazxtXquyw3Ph0JN896fGfjwDzt+mKopiuZwjw@mail.gmail.com>
References: <1378408625-18415-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Andy Zhou <azhou@nicira.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35398 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab3IETZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:25:21 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2343959pab.1
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 12:25:20 -0700 (PDT)
In-Reply-To: <1378408625-18415-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 9:17 PM, Jesse Gross <jesse@nicira.com> wrote:
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -1981,6 +1981,7 @@ nla_put_failure:
>   * Returns zero if successful or a negative error code. */
>  int ovs_flow_init(void)
>  {
> +       BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));

> -} __aligned(__alignof__(long));
> +} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */

These don't match: the struct definition says aligned to 4 or 8 bytes, the check
checks for a multiple of the alignment of "long", which is 2, 4 or 8.

Anyway, BITS_PER_LONG/8 is always a multiple of __alignof__(long), so your
check will never fail.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
