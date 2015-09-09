From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 1/3] net: switchdev: extract switchdev_obj_vlan
Date: Wed, 9 Sep 2015 09:12:58 -0700
Message-ID: <CAE4R7bCZGg5avwiMKzZQC+GRUgJOcUB87rHjSgveh=GWJFnLbA@mail.gmail.com>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1441745275-13200-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33760 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbIIQNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 12:13:19 -0400
Received: by obbbh8 with SMTP id bh8so11993347obb.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 09:13:18 -0700 (PDT)
In-Reply-To: <1441745275-13200-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 8, 2015 at 1:47 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Move the switchdev_obj_vlan structure out of the switchdev_obj union.
>
> This lightens the switchdev_obj structure and allows drivers to access
> the object transaction and callback directly from a switchdev_obj_vlan.
> This is more consistent and convenient for add and dump operations.
>
> The patch updates bridge, the Rocker driver and DSA accordingly.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

[cut]

> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 16c1c43..9923a97 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -397,7 +397,7 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
>  EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
>
>  struct switchdev_vlan_dump {
> -       struct switchdev_obj obj;
> +       struct switchdev_obj_vlan vlan; /* must be first */
>         struct sk_buff *skb;
>         u32 filter_mask;
>         u16 flags;
> @@ -439,9 +439,8 @@ static int switchdev_port_vlan_dump_put(struct net_device *dev,
>  static int switchdev_port_vlan_dump_cb(struct net_device *dev,
>                                        struct switchdev_obj *obj)
>  {
> -       struct switchdev_vlan_dump *dump =
> -               container_of(obj, struct switchdev_vlan_dump, obj);
> -       struct switchdev_obj_vlan *vlan = &dump->obj.u.vlan;
> +       struct switchdev_vlan_dump *dump = (struct switchdev_vlan_dump *) obj;
> +       struct switchdev_obj_vlan *vlan = (struct switchdev_obj_vlan *) obj;

Same comment as Andrew's: use container_of() rather than casting for
both of the use-cases above.  (And don't require inner-structure to be
fist in outer structure).
