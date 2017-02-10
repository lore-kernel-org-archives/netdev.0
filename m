From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net] net/mlx5e: Add preemption enable/disable around
 TC statistics upcall
Date: Fri, 10 Feb 2017 18:21:25 +0200
Message-ID: <CAJ3xEMjuBqrJrQatVroLdF49rxzdF+9a1aP8b3mJSqUyS63-5A@mail.gmail.com>
References: <1486654723-25777-1-git-send-email-ogerlitz@mellanox.com> <20170209173441.1f1eb96e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33707 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752550AbdBJQa6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 11:30:58 -0500
Received: by mail-oi0-f67.google.com with SMTP id j15so2892235oih.0
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 08:30:51 -0800 (PST)
In-Reply-To: <20170209173441.1f1eb96e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 3:34 AM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> On Thu,  9 Feb 2017 17:38:43 +0200, Or Gerlitz wrote:
>> Running with CONFIG_PREEMPT set, I get a
>>
>> BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793
>>
>> asserion from the TC action (mirred) stats_update callback, when the do
>>
>>       _bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)
>>
>> As done by commit 66860be "nfp: bpf: allow offloaded filters to update stats",
>> disabling/enabling preemption around the TC upcall solves that.
>>
>> Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>>
>> I marked it as RFC, since I wasn't fully sure on the nature of the
>> problem, nor if this is the direction we should take to the fix.

> I think it's the right fix

Do you under the problem? what's wrong with the call done in the TC
action code w.r.t preemption?

does it make sense to do this (say) 100K times/sec?

> for net-next we could perhaps redo the
> tcf_action_stats_update() helper so that it takes care of preemption and
> the iteration so more people don't trip over this?

maybe, lets 1st understand that deeper, hopefully you can assist..
