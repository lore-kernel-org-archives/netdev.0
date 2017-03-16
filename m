From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v2 4/4] Openvswitch:
 Refactor sample and recirc actions implementation
Date: Thu, 16 Mar 2017 10:29:02 -0700
Message-ID: <CAOrHB_Dce9dAwatuDf-FFpf6mSr_mpy5RypncEXgFACd8BFf8Q@mail.gmail.com>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org> <1489532891-33497-5-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53190 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752205AbdCPR30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:29:26 -0400
Received: from mfilter46-d.gandi.net (mfilter46-d.gandi.net [217.70.178.177])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 4E0941720F0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:29:04 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter46-d.gandi.net (mfilter46-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id UkADcrtVX1iV for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 18:29:02 +0100 (CET)
Received: from mail-wr0-f174.google.com (mail-wr0-f174.google.com [209.85.128.174])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id EAB8C172094
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:29:02 +0100 (CET)
Received: by mail-wr0-f174.google.com with SMTP id l37so36966361wrc.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:29:02 -0700 (PDT)
In-Reply-To: <1489532891-33497-5-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 4:08 PM, Andy Zhou <azhou@ovn.org> wrote:
> Added execute_or_defer_actions() that both sample and recirc
> action's implementation can use.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/actions.c | 96 +++++++++++++++++++++++++++++------------------
>  1 file changed, 59 insertions(+), 37 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1638370..fd7d903 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
...
...
> @@ -1286,6 +1262,52 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         return 0;
>  }
>
> +static int execute_or_defer_actions(struct datapath *dp, struct sk_buff *skb,
> +                                   struct sw_flow_key *clone,
> +                                   struct sw_flow_key *key,
> +                                   u32 *recirc_id,
> +                                   const struct nlattr *actions, int len)
> +{

The action pointer can be checked if it is recirc or sample action. so
no need to pass pointer to recirc id.
we can pass the last and clone_key flags to this function to clone the
skb and key in this function itself. This would make code bit easy to
read.
