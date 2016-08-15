From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 14:34:00 +0200
Message-ID: <20160815123400.GH2024@nanopsycho>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
 <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amir@vadai.me>, Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33718 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbcHOMeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 08:34:03 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so10924155wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 05:34:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 15, 2016 at 12:08:10PM CEST, jhs@mojatatu.com wrote:
>On 16-08-15 05:08 AM, Amir Vadai wrote:
>> On Mon, Aug 15, 2016 at 11:17:40AM +0300, Amir Vadai wrote:
>> > On Mon, Aug 15, 2016 at 09:11:22AM +0200, Jiri Pirko wrote:
>> > > Sun, Aug 14, 2016 at 07:53:30PM CEST, xiyou.wangcong@gmail.com wrote:
>
>> > 
>> > Thanks,
>> > Amir
>> 
>> Any objection to the following?
>> 
>> # ENCAP rule
>> tc filter add dev $ETH protocol ip parent ffff: prio 10 \
>> 		flower ip_proto 1 \
>> 		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \
>> 		action mirred egress redirect dev $VXLAN
>
>Assuming $VXLAN is actually not a linux netdev of type vxlan?
>then the action does vxlan encap redirect sends it to the $VXLAN
>dev with encapsulation in place.
>Sounds to me like a name like "vxlan" would be more usable. Example:

I believe those are generic tunelling data


>
>tc filter add dev $ETH protocol ip parent ffff: prio 10 ..
>action vxlan encap src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 ....
>action mirred egress redirect dev eth0
>
>> 
>> # DECAP rule
>> tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
>> 		flower \
>> 			enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
>> 			ip_proto 1 \
>> 		action mirred egress redirect dev $ETH
>> 
>
>And a decap would be of the form:
>tc filter add dev $ETH protocol ip parent ffff: prio 10 ..
>action vxlan decap

That's right. Amir, don't you need decap here to drop the tunnel
metadata?


>
>i.e there is no redirect needed here, no?
>
>cheers,
>jamal
