From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 5/6] geneve: Consolidate Geneve functionality in
 single module.
Date: Wed, 12 Aug 2015 14:55:35 -0700
Message-ID: <CAEP_g=8zvvosyueA-gudpYq1pCi4dCusW33wcCscpga8JLWz-w@mail.gmail.com>
References: <1439356673-21844-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35196 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbHLVz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:55:56 -0400
Received: by lbcbn3 with SMTP id bn3so17089946lbc.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 14:55:54 -0700 (PDT)
In-Reply-To: <1439356673-21844-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index c18f9e6..0002ab7 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -181,7 +181,7 @@ config VXLAN
>
>  config GENEVE
>         tristate "Generic Network Virtualization Encapsulation netdev"
> -       depends on INET && GENEVE_CORE
> +       depends on INET
>         select NET_IP_TUNNEL

I think this now needs to select NET_UDP_TUNNEL instead of NET_IP_TUNNEL.

I would also drop "netdev" from the end of the title since there is no
longer a split between the netdev and library.

The farther I go in the series, the more that I hope that we can avoid
the use of collect_md_tun. It really seems to add a lot of special
cases.
