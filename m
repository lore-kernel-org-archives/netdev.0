From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net] net: sched: set xt_tgchk_param par.net properly in ipt_init_target
Date: Tue, 8 Aug 2017 18:34:50 +1200
Message-ID: <CADvbK_e3c2wwY0TbmXqXmnw4hxZxKfBqDWsEFrt1NHXpQj3JTw@mail.gmail.com>
References: <5ac3422182618f34f24d0c52cfa8f922ea7c397e.1502158407.git.lucien.xin@gmail.com>
 <20170808053021.GB1853@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33668 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdHHGev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 02:34:51 -0400
Received: by mail-qt0-f196.google.com with SMTP id u19so2507335qtc.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 23:34:51 -0700 (PDT)
In-Reply-To: <20170808053021.GB1853@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 5:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Aug 08, 2017 at 04:13:27AM CEST, lucien.xin@gmail.com wrote:
>>Now xt_tgchk_param par in ipt_init_target is a local varibale,
>>par.net is not initialized there. Later when xt_check_target
>>calls target's checkentry in which it may access par.net, it
>>would cause kernel panic.
>>
>>Jaroslav found this panic when running:
>>
>>  # ip link add TestIface type dummy
>>  # tc qd add dev TestIface ingress handle ffff:
>>  # tc filter add dev TestIface parent ffff: u32 match u32 0 0 \
>>    action xt -j CONNMARK --set-mark 4
>>
>>This patch is to pass net param into ipt_init_target and set
>>par.net with it properly in there.
>>
>>v1->v2:
>>  As Wang Cong pointed, I missed ipt_net_id != xt_net_id, so fix
>>  it by also passing net_id to __tcf_ipt_init.
>>
>>Reported-by: Jaroslav Aster <jaster@redhat.com>
>>Signed-off-by: Xin Long <lucien.xin@gmail.com>
>
> Fixes what? You need to have "Fixes" tag for net patches.
Fixes: ecb2421b5ddf ("netfilter: add and use nf_ct_netns_get/put")

Thanks, I will repost
