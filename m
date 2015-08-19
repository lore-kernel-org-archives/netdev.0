From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 5/9] geneve: Add support to collect tunnel metadata.
Date: Tue, 18 Aug 2015 18:07:28 -0700
Message-ID: <CAEP_g=-gJeMDi_agxOmuvhvLwKpQeQZAmy55MWenvr_1bwt2Gg@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34530 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbHSBHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 21:07:49 -0400
Received: by ykdt205 with SMTP id t205so177177498ykd.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 18:07:48 -0700 (PDT)
In-Reply-To: <1439845905-31666-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 546494d..cb2d874 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> +static int geneve_configure(struct net *net, struct net_device *dev,
> +                           __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
> +                           __u16 dst_port, bool metadata)
[...]
> -       if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
> -               return -EINVAL;
> +       if (metadata && rtnl_dereference(gn->collect_md_tun))
> +               return -EEXIST;

This will allow you to configure a collect_md_tun devices and normal
devices on top of each other, even though the latter will never get
hit in that situation.
