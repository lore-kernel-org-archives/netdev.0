From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: check the length of skb after
 nf_bridge_maybe_copy_header()
Date: Mon, 03 Jan 2011 09:22:14 -0800 (PST)
Message-ID: <20110103.092214.193706896.davem@davemloft.net>
References: <1293284490-17114-1-git-send-email-xiaosuo@gmail.com>
	<20101231.111003.48499853.davem@davemloft.net>
	<AANLkTingFk8qJ8tBwSRCxD=9k-0O3GnTv9V9TbF4N=bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932162Ab1ACRVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 12:21:43 -0500
In-Reply-To: <AANLkTingFk8qJ8tBwSRCxD=9k-0O3GnTv9V9TbF4N=bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 3 Jan 2011 18:44:59 +0800

> On Sat, Jan 1, 2011 at 3:10 AM, David Miller <davem@davemloft.net> wrote:
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Sat, 25 Dec 2010 21:41:30 +0800
>>
>>> Since nf_bridge_maybe_copy_header() may change the length of skb,
>>> we should check the length of skb after it to handle the ppoe skbs.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>
>> This is really strange.
>>
>> packet_length() subtracts VLAN_HLEN from the value it returns, so the
>> correct fix seems to be to make this function handle the PPPOE case
>> too.
>>
> 
> It is correct. The actual MTU of 802.1q frame is 4 bytes larger. For
> example, the MTU of ethernet is normally 1500, however the actual MTU
> of the 802.1Q is 1504.

Yes, I understand this, but I don't see why packet_length() cannot
simply account for PPPOE's encapsulation overhead just as it does for
VLAN's special MTU considerations.
