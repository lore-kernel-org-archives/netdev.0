From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Mon, 22 Aug 2016 20:51:37 +0200
Message-ID: <20160822205137.30cda14f@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
        <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amir@vadai.me>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34030 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753087AbcHVSvn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 14:51:43 -0400
In-Reply-To: <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016 21:15:41 +0300, Or Gerlitz wrote:
> Jiri B > I understand the motivation for the decap action. However, what would
> Jiri B > happen if someone does not include it?
> 
> The MD set by the (say) vxlan device will not be "consumed" (cleared)
> and would be keep travelling with the SKB

Of course it would. That's not what I meant by the question :-)

There are three options:

1. It does not matter, as the metadata_dst will be freed anyway before
   it reaches tx path. This means we do not need the 'decap' action.

2. We may run into problems like tx path seeing the metadata_dst that
   it should not see. This means either this situation or such
   configuration must be prevented somehow.

3. The metadata_dst can reach the tx path but it doesn't matter, as it
   would just mean the packet is encapsulated into the same outer
   headers it was received with or the metadata_dst would be ignored
   (for non-tunnel interfaces).

Which one is it? Quickly looking into the code, tcf_mirred calls
dev_queue_xmit which indicates it's either 2 or 3. If it's 3., it
should be explained in the patch description (especially the non-tunnel
interface case) and documented.

 Jiri
