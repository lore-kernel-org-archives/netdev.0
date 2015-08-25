From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3 net-next 5/8] geneve: Add support to collect tunnel metadata.
Date: Mon, 24 Aug 2015 18:42:23 -0700
Message-ID: <CAEP_g=_iA6FA4wboFpd_dRXnhQs4u9H7XFv5ACopv-2gy6g5Ew@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com> <1440438195-5695-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36379 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbbHYBmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 21:42:44 -0400
Received: by lbbpu9 with SMTP id pu9so90725037lbb.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 18:42:43 -0700 (PDT)
In-Reply-To: <1440438195-5695-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 0a6d974..c05bc13 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -141,10 +190,15 @@ drop:
>  /* Setup stats when device is created */
>  static int geneve_init(struct net_device *dev)
>  {
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +
>         dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
>         if (!dev->tstats)
>                 return -ENOMEM;
>
> +       if (geneve->collect_md)
> +               dev->features |= NETIF_F_NETNS_LOCAL;

I was going back and forth on whether this is the right thing to do.
Is it any weirder to allow this than to move a normal tunnel device
across namespaces?
