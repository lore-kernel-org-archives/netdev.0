From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 12 Jun 2012 08:51:22 +0200
Message-ID: <CAMGsXDSsSMWfrV1vjnqkWH45ypZw+ZtYF7=ytc79MWRJ5RF5jQ@mail.gmail.com>
References: <20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
	<20120602111335.0b94fb59@stein>
	<loom.20120611T175322-643@post.gmane.org>
	<20120611204925.GA7070@electric-eye.fr.zoreil.com>
	<CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
	<20120611215203.GA8860@electric-eye.fr.zoreil.com>
	<CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com>
	<20120612052631.GA14567@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41378 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2FLGvX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 02:51:23 -0400
Received: by pbbrp8 with SMTP id rp8so383682pbb.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 23:51:23 -0700 (PDT)
In-Reply-To: <20120612052631.GA14567@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

I tried your patch, so far no exception has been generated (uptime 1
hour) . I'll keep it running for 1 day and then I'll come back to you.
Anyway thanks for the patch.

Regards
Tomas

On Tue, Jun 12, 2012 at 7:26 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Tomas Papan <tomas.papan@gmail.com> :
> [...]
>> [ =C2=A0 =C2=A02.780758] r8169 0000:03:00.0: eth1: RTL8168e/8111e at
>> 0xffffc9000001c000, 80:ee:73:10:ad:44, XID 0c200000 IRQ 46
>
> Let's see if it behaves like RTL_GIGA_MAC_VER_34.
>
> Can you try the patch below ?
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index bbacb37..da46588 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -3766,6 +3766,7 @@ static void rtl_init_rxcfg(struct rtl8169_priva=
te *tp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case RTL_GIGA_MAC_VER_22:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case RTL_GIGA_MAC_VER_23:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case RTL_GIGA_MAC_VER_24:
> + =C2=A0 =C2=A0 =C2=A0 case RTL_GIGA_MAC_VER_33:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0RTL_W32(RxConf=
ig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0default:
>
>
