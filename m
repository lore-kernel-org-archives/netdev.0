From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 06:08:10 -0400
Message-ID: <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33528 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbcHOKIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 06:08:17 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so3129306ith.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 03:08:16 -0700 (PDT)
In-Reply-To: <20160815090804.GB19058@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-15 05:08 AM, Amir Vadai wrote:
> On Mon, Aug 15, 2016 at 11:17:40AM +0300, Amir Vadai wrote:
>> On Mon, Aug 15, 2016 at 09:11:22AM +0200, Jiri Pirko wrote:
>>> Sun, Aug 14, 2016 at 07:53:30PM CEST, xiyou.wangcong@gmail.com wrote:

>>
>> Thanks,
>> Amir
>
> Any objection to the following?
>
> # ENCAP rule
> tc filter add dev $ETH protocol ip parent ffff: prio 10 \
> 		flower ip_proto 1 \
> 		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \
> 		action mirred egress redirect dev $VXLAN

Assuming $VXLAN is actually not a linux netdev of type vxlan?
then the action does vxlan encap redirect sends it to the $VXLAN
dev with encapsulation in place.
Sounds to me like a name like "vxlan" would be more usable. Example:

tc filter add dev $ETH protocol ip parent ffff: prio 10 ..
action vxlan encap src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 ....
action mirred egress redirect dev eth0

>
> # DECAP rule
> tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
> 		flower \
> 			enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
> 			ip_proto 1 \
> 		action mirred egress redirect dev $ETH
>

And a decap would be of the form:
tc filter add dev $ETH protocol ip parent ffff: prio 10 ..
action vxlan decap

i.e there is no redirect needed here, no?

cheers,
jamal
