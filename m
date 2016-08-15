From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] flow_dissector: Get vlan info from
 skb->vlan_tci instead of skb->data
Date: Mon, 15 Aug 2016 18:51:38 +0300
Message-ID: <CAJL1qvHL27cFDYHwyKFiRoGx4FERMWY_e8ybo3ihoRWhFZLUMg@mail.gmail.com>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-2-git-send-email-hadarh@mellanox.com> <e16e8104-c010-e812-74c8-d28960e23643@lab.ntt.co.jp>
 <CAJL1qvEncNo-10vd387jdLj2Y+Xc_-Ms7rKHU6bQh=QO43ic5w@mail.gmail.com> <cdfa6f93-631e-8875-a60f-871507f8a3c2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33794 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbcHOPvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 11:51:40 -0400
Received: by mail-oi0-f66.google.com with SMTP id t127so4706377oie.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 08:51:39 -0700 (PDT)
In-Reply-To: <cdfa6f93-631e-8875-a60f-871507f8a3c2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 5:38 AM, Toshiaki Makita
<toshiaki.makita1@gmail.com> wrote:
> On 16/08/14 (日) 23:58, Hadar Hen Zion wrote:
>>
>> On Fri, Aug 12, 2016 at 9:36 AM, Toshiaki Makita
>> <makita.toshiaki@lab.ntt.co.jp> wrote:
>>>
>>> On 2016/08/10 22:32, Hadar Hen Zion wrote:
>>>>
>>>> Early in the datapath skb_vlan_untag function is called, stripped
>>>> the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>>>>
>>>> The current dissection doesn't handle vlan packets correctly.  Vlan
>>>> doesn't exist in skb->data anymore when applying flow dissection on the
>>>> skb, fix that.
>>>
>>>
>>> RPS (and flow-dissector called in RPS) is performed before vlan-strip in
>>> __netif_receive_skb_core().
>>
>>
>> right, I'll fix it to v2.
>>
>>> Also, in cases skb is tagged with multiple vlan headers (typical when
>>> using 802.1ad), the second level vlan tag is in skb->data.
>>
>>
>> Currently, flow_dissector doesn't support multiple vlan headers, only
>> one vlan_id field is present.
>> There aren't any flow_dissector "customers" yet for multiple vlan support.
>
>
> Sure, no need to store second level vlan tag information for now.
> The point is that current flow-dissector correctly skips any number of vlan
> tags and get hash value from IP/TCP/UDP headers, so RPS works for multiple
> vlan tagged packets.
>
> Thanks,
> Toshiaki Makita

ok, so we are on the same page.
The flow dissector will correctly skip any number of vlans regardless
if the first vlan is stripped or not.

I also found a dependency between my vlan addition to flower and mlx5
tc offload support so I'm working to fix it for V2.

Thanks,
Hadar
