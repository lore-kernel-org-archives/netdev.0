From: Amir Vadai <amir@vadai.me>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 12:58:09 +0300
Message-ID: <20160815095809.GC19058@office.localdomain>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
 <20160815125039.07809d54@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35158 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbcHOJ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 05:58:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so10257147wmg.2
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 02:58:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160815125039.07809d54@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 12:50:39PM +0300, Shmulik Ladkani wrote:
> On Mon, 15 Aug 2016 12:08:04 +0300, amir@vadai.me wrote:
> > 
> > Any objection to the following?
> > 
> > # ENCAP rule
> > tc filter add dev $ETH protocol ip parent ffff: prio 10 \
> > 		flower ip_proto 1 \
> > 		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \
> 
> Ability to control few tun_flags (e.g. TUNNEL_CSUM, TUNNEL_DONT_FRAGMENT)
> might be useful too.
I guess it should be added when needed. Currenly I don't have a use case
for that.

> 
> > # DECAP rule
> > tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
> > 		flower \
> > 			enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
> > 			ip_proto 1 \
> 
> You might want to match the tunnel's udp port as well, for symmetry.
actually, now that you raise it, the udp port is already an attribute of
the vxlan device. So I think it should be ommitted in both encap and
decap. Selecting the udp port will be done when creating the vxlan
device.

Thanks,
Amir
