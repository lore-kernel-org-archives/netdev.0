From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next V1 1/2] net: Header length compution function
Date: Mon, 28 Jul 2014 14:26:08 -0700
Message-ID: <CAHA+R7NkWxbLM_T202o86G_0MgmpHG71jV+2_fQ3JCjZu9sw1g@mail.gmail.com>
References: <1406546881-21863-1-git-send-email-amirv@mellanox.com>
	<1406546881-21863-2-git-send-email-amirv@mellanox.com>
	<53D66344.2050207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:50750 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbaG1V0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 17:26:10 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so5987399lab.35
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 14:26:09 -0700 (PDT)
In-Reply-To: <53D66344.2050207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2014 at 7:50 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 07/28/2014 04:28 AM, Amir Vadai wrote:
>> +u32 eth_frame_headlen(void *data, unsigned int len)
>> +{
>> +     const struct ethhdr *eth = data;
>> +     struct sk_buff skb;
>> +
>> +     if (unlikely(len < ETH_HLEN))
>> +             return len;
>> +
>> +     skb.protocol = eth->h_proto;
>> +     skb.head = data + ETH_HLEN;
>> +     skb.data = skb.head;
>> +     skb_reset_network_header(&skb);
>> +     skb.len = len - ETH_HLEN;
>> +     skb.data_len = 0;
>> +     return __skb_get_poff(&skb) + ETH_HLEN;
>> +}
>
> I'm still not a big fan of allocating an sk_buff on the stack.  Seems
> like it isn't maintainable and really opens things up to possible issues
> if someone ever extends the __skb_get_poff call.  But I'm not going to
> force the issue since for now this isn't impacting igb or ixgbe.
>

+1

I think you can refactor the code to pass all these input as
arguments instead of a whole skbuff.
