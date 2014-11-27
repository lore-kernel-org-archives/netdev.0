From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 21/21] rocker: Use logical operators on booleans
Date: Thu, 27 Nov 2014 11:04:16 -1000
Message-ID: <CAE4R7bCAfn_bjPoq_pFYDb4S7cR=3jtqS8XQQZc97CHab2561Q@mail.gmail.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
	<1417084826-9875-22-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tu
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35898 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaK0VER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 16:04:17 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so7377436wgg.1
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 13:04:16 -0800 (PST)
In-Reply-To: <1417084826-9875-22-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

On Thu, Nov 27, 2014 at 12:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Thomas Graf <tgraf@suug.ch>
>
> Silences various sparse warnings
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> new in v4
> ---
>  drivers/net/ethernet/rocker/rocker.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 30687bf..fded127 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -2404,17 +2404,17 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
>         }
>
>         priority = ROCKER_PRIORITY_UNKNOWN;
> -       if (vlan_bridging & dflt & wild)
> +       if (vlan_bridging && dflt && wild)
>                 priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
> -       else if (vlan_bridging & dflt & !wild)
> +       else if (vlan_bridging && dflt && !wild)
>                 priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
> -       else if (vlan_bridging & !dflt)
> +       else if (vlan_bridging && !dflt)
>                 priority = ROCKER_PRIORITY_BRIDGING_VLAN;
> -       else if (!vlan_bridging & dflt & wild)
> +       else if (!vlan_bridging && dflt && wild)
>                 priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
> -       else if (!vlan_bridging & dflt & !wild)
> +       else if (!vlan_bridging && dflt && !wild)
>                 priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
> -       else if (!vlan_bridging & !dflt)
> +       else if (!vlan_bridging && !dflt)
>                 priority = ROCKER_PRIORITY_BRIDGING_TENANT;
>
>         entry->key.priority = priority;
> @@ -3010,9 +3010,9 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
>         bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
>         bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
>
> -       if (learned & removing)
> +       if (learned && removing)
>                 br_fdb_external_learn_del(lw->dev, lw->addr, lw->vid);
> -       else if (learned & !removing)
> +       else if (learned && !removing)
>                 br_fdb_external_learn_add(lw->dev, lw->addr, lw->vid);
>
>         kfree(work);
> --
> 1.9.3
>
