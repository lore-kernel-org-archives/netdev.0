From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [Patch net] bonding: commit link status change after propose
Date: Tue, 25 Jul 2017 15:14:35 -0700
Message-ID: <CAF2d9jiW9uv63Yq-52jObPO1nPRwFHQXZzx0PsQU_n=SgCi-fA@mail.gmail.com>
References: <20170725164425.9112-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>, benjamin.gilbert@coreos.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:37694 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdGYWO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 18:14:56 -0400
Received: by mail-io0-f170.google.com with SMTP id c74so61199986iod.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 15:14:56 -0700 (PDT)
In-Reply-To: <20170725164425.9112-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 9:44 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Commit de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
> moves link status commitment into bond_mii_monitor(), but it still relies
> on the return value of bond_miimon_inspect() as the hint. We need to return
> non-zero as long as we propose a link status change.
>
> Fixes: de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
> Reported-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
> Tested-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 181839d6fbea..9bee6c1c70cc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2050,6 +2050,7 @@ static int bond_miimon_inspect(struct bonding *bond)
>                                 continue;
>
>                         bond_propose_link_state(slave, BOND_LINK_FAIL);
> +                       commit++;
>                         slave->delay = bond->params.downdelay;
>                         if (slave->delay) {
>                                 netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
> @@ -2088,6 +2089,7 @@ static int bond_miimon_inspect(struct bonding *bond)
>                                 continue;
>
>                         bond_propose_link_state(slave, BOND_LINK_BACK);
> +                       commit++;
>                         slave->delay = bond->params.updelay;
>
>                         if (slave->delay) {
> --
> 2.13.0
>
