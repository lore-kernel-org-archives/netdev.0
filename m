From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Fri, 16 May 2014 15:17:01 -0400 (EDT)
Message-ID: <20140516.151701.1642109390027874890.davem@davemloft.net>
References: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140515.163400.1536463708975272927.davem@davemloft.net>
	<CAM_iQpVGG92NMYTJuCXg3yhCkVDyL3Tf=5HJy6n2V1Z89yySzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317AbaEPTRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 15:17:04 -0400
In-Reply-To: <CAM_iQpVGG92NMYTJuCXg3yhCkVDyL3Tf=5HJy6n2V1Z89yySzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 16 May 2014 10:52:09 -0700

> On Thu, May 15, 2014 at 1:34 PM, David Miller <davem@davemloft.net> wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> Date: Wed, 14 May 2014 11:39:22 -0700
>>
>>> From: Cong Wang <cwang@twopensource.com>
>>>
>>> In a corner case where I redirect the packets from veth to lo,
>>> packets are dropped silently when entering IP stack. This is
>>> due to we have a different MAC addr on veth, so the packets are
>>> marked as PACKET_OTHERHOST. And after they are redirect to lo,
>>> this value is kept since lo has the same MAC addr with the packets.
>>> Loopback should explicitly set it to PACKET_HOST before calling
>>> eth_type_trans() for this specific case.
>>>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>>
>> How exactly are you performing this redirection?
> 
> Oh, I meant using tc mirred action to redirect packets from vethX to lo.
> Sorry for confusing.

I think you can't expect arbitrary redirection of packets from an outgoing
interface back into the stack via loopback to work like that.

The is never any legitimate reason in this type of flow to override the
decisions made by eth_type_trans() as to the disposition of the packet type.

I'm not applying this, sorry.
