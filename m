From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] bridge: mdb: fix double add notification
Date: Mon, 13 Jul 2015 20:53:38 -0700
Message-ID: <CAHA+R7OJ0bQ_vG7Tt8jZ8gkdjevjXL-4ER7ZhTjL1CmARsFqgw@mail.gmail.com>
References: <1436794579-4188-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>, Cong Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:35887 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbbGNDxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 23:53:39 -0400
Received: by ykay190 with SMTP id y190so56998827yka.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 20:53:38 -0700 (PDT)
In-Reply-To: <1436794579-4188-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 6:36 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> Since the mdb add/del code was introduced there have been 2 br_mdb_notify
> calls when doing br_mdb_add() resulting in 2 notifications on each add.
>
> Example:
>  Command: bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
>  Before patch:
>  root@debian:~# bridge monitor all
>  [MDB]dev br0 port eth1 grp 239.0.0.1 permanent
>  [MDB]dev br0 port eth1 grp 239.0.0.1 permanent
>
>  After patch:
>  root@debian:~# bridge monitor all
>  [MDB]dev br0 port eth1 grp 239.0.0.1 permanent
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: cfd567543590 ("bridge: add support of adding and deleting mdb entries")
> ---
>  net/bridge/br_mdb.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> index c11cf2611db0..1198a3dbad95 100644
> --- a/net/bridge/br_mdb.c
> +++ b/net/bridge/br_mdb.c
> @@ -351,7 +351,6 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
>         if (state == MDB_TEMPORARY)
>                 mod_timer(&p->timer, now + br->multicast_membership_interval);
>
> -       br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
>         return 0;
>  }

Looks good to me.

And probably we can convert existing __br_mdb_notify() to using
non-atomic allocation too, but that is for net-next.
