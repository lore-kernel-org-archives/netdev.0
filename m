From: Amos Kong <kongjianjun@gmail.com>
Subject: Re: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Fri, 23 Aug 2013 10:49:48 +0800
Message-ID: <CAFeW=pY2xT7DB-Wrpi7MSyri5UD1quR76PR5ziv+YkNmC2L5TQ@mail.gmail.com>
References: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	eric.dumazet@gmail.com, Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:54958 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab3HWCtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 22:49:49 -0400
Received: by mail-wi0-f170.google.com with SMTP id hi8so1594683wib.3
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 19:49:48 -0700 (PDT)
In-Reply-To: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 5:21 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Some slave devices may have set a dev->needed_headroom value which is
> different than the default one, most likely in order to prepend a
> hardware descriptor in front of the Ethernet frame to send. Whenever a
> new slave is added to a bridge, ensure that we update the
> needed_headroom value accordingly to account for the slave
> needed_headroom value.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/bridge/br_if.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index aa6c9a8..c41d5fb 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -383,6 +383,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>
>         netdev_update_features(br->dev);
>
> +       if (br->dev->needed_headroom < dev->needed_headroom)
> +               br->dev->needed_headroom = dev->needed_headroom;
> +

do we need to update 'br->dev->needed_headroom' in br_del_if()?

if (br->dev->needed_headroom == dev->needed_headroom)
    br->dev->needed_headroom = ....;


>         spin_lock_bh(&br->lock);
>         changed_addr = br_stp_recalculate_bridge_id(br);
>
> --
> 1.8.1.2
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
