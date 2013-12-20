From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 10:55:34 -0800
Message-ID: <CAM_iQpWz0NP_6vtYhHSSDW1p3HdALoiNm7JkwL=1-XErHOZ14w@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>
	<52B434A9.9070408@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:49472 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3LTSze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:55:34 -0500
Received: by mail-ob0-f172.google.com with SMTP id gq1so3154437obb.31
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:55:34 -0800 (PST)
In-Reply-To: <52B434A9.9070408@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 4:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Very impressive catch Eric. I would have 100% caught this with testing
> (but you caught it by inspecting code!).
> A simple test that dumps all the actions of a specific type would do.
> Example in your case, Cong:
> tc actions ls action mirred
>

Are you sure?? It is in my test case right after David merged it,
I still don't see any bug it reports so far.

For completeness, here is my one of test cases:

ip li add dev dummy0 type dummy
ip li add dev dummy1 type dummy
ip li add dev dummy2 type dummy
tc qdisc del dev $1 ingress
tc qdisc add dev $1 ingress
tc filter add dev $1 parent ffff: protocol ip u32 match ip protocol 1
0xff action mirred egress mirror dev dummy0 action mirred egress
mirror dev dummy1
tc filter add dev $1 parent ffff: protocol ip u32 match ip protocol 1
0xff action mirred egress mirror dev dummy0 action mirred egress
mirror dev dummy2
tc filter show dev $1 parent ffff: && tc action ls action mirred
ip li del dummy0
tc filter show dev $1 parent ffff: && tc action ls action mirred
ip li del dummy1
tc filter show dev $1 parent ffff: && tc action ls action mirred
