From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] flow_dissector: Get vlan info from
 skb->vlan_tci instead of skb->data
Date: Sun, 14 Aug 2016 17:58:53 +0300
Message-ID: <CAJL1qvEncNo-10vd387jdLj2Y+Xc_-Ms7rKHU6bQh=QO43ic5w@mail.gmail.com>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-2-git-send-email-hadarh@mellanox.com> <e16e8104-c010-e812-74c8-d28960e23643@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35623 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbcHNO7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 10:59:50 -0400
Received: by mail-oi0-f65.google.com with SMTP id e80so2655851oig.2
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 07:58:54 -0700 (PDT)
In-Reply-To: <e16e8104-c010-e812-74c8-d28960e23643@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 9:36 AM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2016/08/10 22:32, Hadar Hen Zion wrote:
>> Early in the datapath skb_vlan_untag function is called, stripped
>> the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>>
>> The current dissection doesn't handle vlan packets correctly.  Vlan
>> doesn't exist in skb->data anymore when applying flow dissection on the
>> skb, fix that.
>
> RPS (and flow-dissector called in RPS) is performed before vlan-strip in
> __netif_receive_skb_core().

right, I'll fix it to v2.

> Also, in cases skb is tagged with multiple vlan headers (typical when
> using 802.1ad), the second level vlan tag is in skb->data.

Currently, flow_dissector doesn't support multiple vlan headers, only
one vlan_id field is present.
There aren't any flow_dissector "customers" yet for multiple vlan support.


> So I think you should handle both of skb->vlan_tci and skb->data cases.

Sure, will do it.


>
> Thanks,
> Toshiaki Makita
>
>
