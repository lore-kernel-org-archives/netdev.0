From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 12:50:39 +0300
Message-ID: <20160815125039.07809d54@pixies>
References: <20160814140652.15985-1-amir@vadai.me>
	<CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
	<20160815071121.GA2024@nanopsycho>
	<20160815081740.GA19058@office.localdomain>
	<20160815090804.GB19058@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36500 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbcHOJuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 05:50:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so10172716wmf.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 02:50:51 -0700 (PDT)
In-Reply-To: <20160815090804.GB19058@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2016 12:08:04 +0300, amir@vadai.me wrote:
> 
> Any objection to the following?
> 
> # ENCAP rule
> tc filter add dev $ETH protocol ip parent ffff: prio 10 \
> 		flower ip_proto 1 \
> 		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \

Ability to control few tun_flags (e.g. TUNNEL_CSUM, TUNNEL_DONT_FRAGMENT)
might be useful too.

> # DECAP rule
> tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
> 		flower \
> 			enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
> 			ip_proto 1 \

You might want to match the tunnel's udp port as well, for symmetry.
