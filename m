From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Mon, 22 Aug 2016 19:07:55 +0200
Message-ID: <20160822190755.6a782afe@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38802 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbcHVRIA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 13:08:00 -0400
In-Reply-To: <20160822143834.32422-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016 17:38:34 +0300, Amir Vadai wrote:
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device
> 
> The action will release the metadata created by the tunnel device
> (decap), or set the metadata with the specified values for encap
> operation.

I understand the motivation for the decap action. However, what would
happen if someone does not include it?

Borrowing your example from the cover letter and modifying it, what
would happen in the following case?

$ tc filter add dev vxlan0 protocol ip parent ffff: \
    flower \
  	  enc_src_ip 11.11.0.2 \
  		enc_dst_ip 11.11.0.1 \
  		enc_key_id 11 \
  	  action mirred egress redirect dev vnet0

Thanks,

 Jiri
