From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/6] geneve: Make dst-port configurable.
Date: Wed, 12 Aug 2015 10:00:19 -0700
Message-ID: <CAEP_g=9biFJDxbAFMBB+mbttBnbEkykJx7z24HrhUdjA25YpNg@mail.gmail.com>
References: <1439356660-21754-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33700 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932187AbbHLRAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 13:00:40 -0400
Received: by lalv9 with SMTP id v9so12615891lal.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 10:00:38 -0700 (PDT)
In-Reply-To: <1439356660-21754-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 78d49d1..5e9bab8 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -378,6 +379,11 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>         if (data[IFLA_GENEVE_TOS])
>                 geneve->tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
>
> +       if (data[IFLA_GENEVE_PORT])
> +               geneve->dst_port = htons(nla_get_u16(data[IFLA_GENEVE_PORT]));
> +       else
> +               geneve->dst_port = htons(GENEVE_UDP_PORT);

I think there is a looming compatibility problem: if the request for
an alternate port isn't successful then it will be silently ignored,
which would presumably be confusing to the user when things appeared
to have worked without an error. Perhaps the right thing to do is to
check to see whether you get it back when the configuration is dumped
but it is worth thinking about now.

Presumably IFLA_GENEVE_PORT should be added to geneve_policy.

Not specific to this patch but I think that it will make things
significantly easier in the future if changelink was implemented.
VXLAN has the same issue as well.
