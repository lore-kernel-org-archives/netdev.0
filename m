From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Sun, 14 Aug 2016 10:53:30 -0700
Message-ID: <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
References: <20160814140652.15985-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33719 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcHNRxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 13:53:54 -0400
Received: by mail-io0-f193.google.com with SMTP id y195so4641255iod.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 10:53:54 -0700 (PDT)
In-Reply-To: <20160814140652.15985-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 14, 2016 at 7:06 AM, Amir Vadai <amir@vadai.me> wrote:
> tc qdisc add dev $ETH ingress
>
> # ENCAP rule for ARP
> tc filter add dev $ETH protocol 0x806 parent ffff: prio 11 \
>                 flower \
>                 action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789
>
> # ENCAP rule for ICMP
> tc filter add dev $ETH protocol ip parent ffff: prio 10 \
>                 flower ip_proto 1 \
>                 action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789
>

I don't like this. This makes mirred action unnecessarily
complex, it should really just mirror or redirect packets as
it is, why it should be aware of tunnel information?

I think you probably need to introduce a new tc action
for these tunnel information and pipe it to mirred.
