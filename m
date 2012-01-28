From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 06:41:34 +0100
Message-ID: <CAHXqBF+5WxSzGhrTLMEG1NXcULdnwWDHS8koTr907qRT9H5U8A@mail.gmail.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com> <20120127205903.GG24507@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60652 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab2A1Fly convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 00:41:54 -0500
Received: by iacb35 with SMTP id b35so2895302iac.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 21:41:54 -0800 (PST)
In-Reply-To: <20120127205903.GG24507@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/27 Francois Romieu <romieu@fr.zoreil.com>:
[...]
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -716,7 +722,10 @@ struct rtl8169_private {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*do_ioctl)(struct rtl8169_private *tp=
, struct mii_ioctl_data *data, int cmd);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DECLARE_BITMAP(fla=
gs, RTL_FLAG_MAX);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mutex mutex=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct work_st=
ruct work;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool enabled;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} wk;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned features;

You could pull the "enabled" flag into "flags".

Best Regards,
Micha=C5=82 Miros=C5=82aw
