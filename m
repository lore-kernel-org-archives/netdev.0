From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Tue, 25 Aug 2015 12:03:18 -0700
Message-ID: <CAEP_g=84tg9nPE-PmmPF_rVW_0ctAmjZj-fxRP-Puf9=Da0++g@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com> <1440438195-5695-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33661 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162AbbHYTDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 15:03:40 -0400
Received: by lbbsx3 with SMTP id sx3so106022018lbb.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 12:03:38 -0700 (PDT)
In-Reply-To: <1440438195-5695-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index c05bc13..8eb875d 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -492,36 +813,36 @@ static int geneve_configure(struct net *net, struct net_device *dev,
[...]
> +       gs = geneve_find_sock(gn, geneve->dst_port);
> +       if (gs) {
> +               if (metadata) {
> +                       if (gs->collect_md)
> +                               return -EEXIST;
> +                       else
> +                               return -EPERM;
> +               } else {
> +                       if (gs->collect_md)
> +                               return -EPERM;
> +
> +                       t = geneve_lookup(gn, htons(dst_port),
> +                                         rem_addr, geneve->vni);
> +                       if (t)
> +                               return -EBUSY;
> +               }
> +       }

I like the new structure but unfortunately, I think there is a race.
If two devices are created with conflicting configurations but neither
is brought up then creation of both devices will succeed. However,
when the second one is brought up, it will silently collide with the
first.
