From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 3/4] net: sched: convert cls_flower->egress_dev
 users to tc_setup_cb_egdev infra
Date: Wed, 11 Oct 2017 11:36:26 +0300
Message-ID: <CAJ3xEMiUecFssQSJAQYAu5zVBhtuqVvApGva7yiGcxFhY_hU0A@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-4-jiri@resnulli.us>
 <CAJ3xEMh0cM3FszEjKNNe3aWTjHoDxof9GURgUSMy5k3iSTLg2g@mail.gmail.com>
 <20171010211609.GK2033@nanopsycho> <CAJ3xEMhHf8_bV_EFs2T44ikskm5dzHgiV0GhbW1UZneyO=d8jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
        John Hurley <john.hurley@netronome.com>,
        Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:48509 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756656AbdJKIg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 04:36:28 -0400
Received: by mail-oi0-f68.google.com with SMTP id m198so1704371oig.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 01:36:27 -0700 (PDT)
In-Reply-To: <CAJ3xEMhHf8_bV_EFs2T44ikskm5dzHgiV0GhbW1UZneyO=d8jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 12:47 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Oct 11, 2017 at 12:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 10, 2017 at 10:08:23PM CEST, gerlitz.or@gmail.com wrote:
>>>On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> The only user of cls_flower->egress_dev is mlx5.
>>>
>>>but nfp supports decap action offload too and from the flower code
>>>stand point, I guess they are both the same, right? how does it work there?

>> Apparently they don't use cls_flower->egress_dev.

> John, can you elaborate on that, how do you manage to get away from
> that practice?

Looking on this a little more, it's clearly obvious that both
fl_hw_update_stats and
fl_hw_destroy_filter never set egress_dev on the local variable which
is set down
to the driver through the ndo.

For cases such as decap flow set on virtual SW tunnel device where f->hw_dev is
the egress port, mlx5 fails to internally locate the  driver rule
object and we return -EINVAL
on both cases and hence deletion or stats will not take place.

I verified that in black box manner for both cases of deletion (the
specific filer or the
whole ingress qdisc) and for the stats.

We have per ingress port rules table on the driver and maybe nfp
doesn't and hence
why they  didn't fell on that, not sure, I copied the folks here.

Commit a6e1693129 "net/sched: cls_flower: Set the filter Hardware
device for all use-cases"
tries to fix something and does mention the stats and destroy cases,
but I don't see how
it helps for that :(

I will keep looking next week (starting holiday here now) and try to
get a fix for net and stable.

Or.
