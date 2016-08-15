From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/4] flow_dissector: Get vlan info from
 skb->vlan_tci instead of skb->data
Date: Mon, 15 Aug 2016 20:06:45 +0200
Message-ID: <20160815180645.GM2024@nanopsycho>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
 <e16e8104-c010-e812-74c8-d28960e23643@lab.ntt.co.jp>
 <CAJL1qvEncNo-10vd387jdLj2Y+Xc_-Ms7rKHU6bQh=QO43ic5w@mail.gmail.com>
 <cdfa6f93-631e-8875-a60f-871507f8a3c2@gmail.com>
 <CAJL1qvHL27cFDYHwyKFiRoGx4FERMWY_e8ybo3ihoRWhFZLUMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33239 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbcHOSGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 14:06:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so12412908wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 11:06:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJL1qvHL27cFDYHwyKFiRoGx4FERMWY_e8ybo3ihoRWhFZLUMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 15, 2016 at 05:51:38PM CEST, hadarh@dev.mellanox.co.il wrote:
>On Mon, Aug 15, 2016 at 5:38 AM, Toshiaki Makita
><toshiaki.makita1@gmail.com> wrote:
>> On 16/08/14 (日) 23:58, Hadar Hen Zion wrote:
>>>
>>> On Fri, Aug 12, 2016 at 9:36 AM, Toshiaki Makita
>>> <makita.toshiaki@lab.ntt.co.jp> wrote:
>>>>
>>>> On 2016/08/10 22:32, Hadar Hen Zion wrote:
>>>>>
>>>>> Early in the datapath skb_vlan_untag function is called, stripped
>>>>> the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>>>>>
>>>>> The current dissection doesn't handle vlan packets correctly.  Vlan
>>>>> doesn't exist in skb->data anymore when applying flow dissection on the
>>>>> skb, fix that.
>>>>
>>>>
>>>> RPS (and flow-dissector called in RPS) is performed before vlan-strip in
>>>> __netif_receive_skb_core().
>>>
>>>
>>> right, I'll fix it to v2.
>>>
>>>> Also, in cases skb is tagged with multiple vlan headers (typical when
>>>> using 802.1ad), the second level vlan tag is in skb->data.
>>>
>>>
>>> Currently, flow_dissector doesn't support multiple vlan headers, only
>>> one vlan_id field is present.
>>> There aren't any flow_dissector "customers" yet for multiple vlan support.
>>
>>
>> Sure, no need to store second level vlan tag information for now.
>> The point is that current flow-dissector correctly skips any number of vlan
>> tags and get hash value from IP/TCP/UDP headers, so RPS works for multiple
>> vlan tagged packets.
>>
>> Thanks,
>> Toshiaki Makita
>
>ok, so we are on the same page.
>The flow dissector will correctly skip any number of vlans regardless
>if the first vlan is stripped or not.


On RX the first vlan is always stripped either by hw or by skb_vlan_untag.
On TX the first vlan is also stripped as validate_xmit_skb_list which
pushes vlan header is called just before dev_hard_start_xmit.

So I believe you can safely work just with skb->vlan_*
