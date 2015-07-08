From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2 1/5] ipvlan: remove counters of ipv4 and ipv6 addresses
Date: Tue, 7 Jul 2015 20:59:30 -0700
Message-ID: <CAF2d9jhTv9gimJPF+xbf=gK32t2suy2Hb0eeqcfJeYbXbvV-wQ@mail.gmail.com>
References: <20150703125132.24121.50592.stgit@buzz> <20150703125836.24121.15213.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:36046 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbbGHD7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 23:59:51 -0400
Received: by ykey15 with SMTP id y15so735042yke.3
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 20:59:50 -0700 (PDT)
In-Reply-To: <20150703125836.24121.15213.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 3, 2015 at 5:58 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> They are unused after commit f631c44bbe15 ("ipvlan: Always set broadcast bit in
> multicast filter").
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  drivers/net/ipvlan/ipvlan.h      |    2 -
>  drivers/net/ipvlan/ipvlan_main.c |   65 +++++++++++++++-----------------------
>  2 files changed, 26 insertions(+), 41 deletions(-)
>

> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 1acc283160d9..62577b3f01f2 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -627,8 +622,9 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>         memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
>         addr->atype = IPVL_IPV6;
>         list_add_tail(&addr->anode, &ipvlan->addrs);
> -       ipvlan->ipv6cnt++;
> -       /* If the interface is not up, the address will be added to the hash
> +
> +       /*
> +        * If the interface is not up, the address will be added to the hash
Why? Preferred commenting style in net is
      /* multi-line
       * comment
       */
>          * list by ipvlan_open.
>          */
>         if (netif_running(ipvlan->dev))
> @@ -642,16 +638,11 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>         struct ipvl_addr *addr;
>
>         addr = ipvlan_find_addr(ipvlan, ip6_addr, true);
> -       if (!addr)
> -               return;
> -
> -       ipvlan_ht_addr_del(addr, true);
> -       list_del(&addr->anode);
> -       ipvlan->ipv6cnt--;
> -       WARN_ON(ipvlan->ipv6cnt < 0);
> -       kfree_rcu(addr, rcu);
> -
> -       return;
> +       if (addr) {
> +               ipvlan_ht_addr_del(addr, true);
> +               list_del(&addr->anode);
> +               kfree_rcu(addr, rcu);
> +       }
This delta is unnecessarily big and can be reduced to deleting just two lines.
>  }
>
>  static int ipvlan_addr6_event(struct notifier_block *unused,
> @@ -699,8 +690,9 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>         memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
>         addr->atype = IPVL_IPV4;
>         list_add_tail(&addr->anode, &ipvlan->addrs);
> -       ipvlan->ipv4cnt++;
> -       /* If the interface is not up, the address will be added to the hash
> +
> +       /*
> +        * If the interface is not up, the address will be added to the hash
same here (multi line comments)
>          * list by ipvlan_open.
>          */
>         if (netif_running(ipvlan->dev))
> @@ -714,16 +706,11 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>         struct ipvl_addr *addr;
>
>         addr = ipvlan_find_addr(ipvlan, ip4_addr, false);
> -       if (!addr)
> -               return;
> -
> -       ipvlan_ht_addr_del(addr, true);
> -       list_del(&addr->anode);
> -       ipvlan->ipv4cnt--;
> -       WARN_ON(ipvlan->ipv4cnt < 0);
> -       kfree_rcu(addr, rcu);
> -
> -       return;
> +       if (addr) {
> +               ipvlan_ht_addr_del(addr, true);
> +               list_del(&addr->anode);
> +               kfree_rcu(addr, rcu);
> +       }
This delta is unnecessarily big and can be reduced to deleting just two lines.
>  }
>
>  static int ipvlan_addr4_event(struct notifier_block *unused,
>
