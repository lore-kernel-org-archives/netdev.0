From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 13:24:36 +0300
Message-ID: <20160815132436.0d1e34b6@pixies>
References: <20160814140652.15985-1-amir@vadai.me>
	<CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
	<20160815071121.GA2024@nanopsycho>
	<20160815081740.GA19058@office.localdomain>
	<20160815090804.GB19058@office.localdomain>
	<faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amir@vadai.me>, Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33013 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcHOKYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 06:24:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so10385026wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 03:24:48 -0700 (PDT)
In-Reply-To: <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2016 06:08:10 -0400, jhs@mojatatu.com wrote:
> On 16-08-15 05:08 AM, Amir Vadai wrote:
> > # ENCAP rule
> > tc filter add dev $ETH protocol ip parent ffff: prio 10 \
> > 		flower ip_proto 1 \
> > 		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \
> > 		action mirred egress redirect dev $VXLAN
> 
> Assuming $VXLAN is actually not a linux netdev of type vxlan?
> then the action does vxlan encap redirect sends it to the $VXLAN
> dev with encapsulation in place.

I assume Amir refers to vxlan netdev in VXLAN_F_COLLECT_METADATA mode,
using the tun_info metadata found in skb_metadata_dst.
The action is supposed to assign the tun metadata.
