From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: check the length of skb after
 nf_bridge_maybe_copy_header()
Date: Mon, 03 Jan 2011 12:13:36 -0800 (PST)
Message-ID: <20110103.121336.212692696.davem@davemloft.net>
References: <AANLkTingFk8qJ8tBwSRCxD=9k-0O3GnTv9V9TbF4N=bg@mail.gmail.com>
	<20110103.092214.193706896.davem@davemloft.net>
	<20110103101533.3f98b311@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38268
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751257Ab1ACUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 15:13:05 -0500
In-Reply-To: <20110103101533.3f98b311@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 3 Jan 2011 10:15:33 -0800

> On Mon, 03 Jan 2011 09:22:14 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Mon, 3 Jan 2011 18:44:59 +0800
>> 
>> > On Sat, Jan 1, 2011 at 3:10 AM, David Miller <davem@davemloft.net> wrote:
>> >> From: Changli Gao <xiaosuo@gmail.com>
>> >> Date: Sat, 25 Dec 2010 21:41:30 +0800
>> >>
>> >>> Since nf_bridge_maybe_copy_header() may change the length of skb,
>> >>> we should check the length of skb after it to handle the ppoe skbs.
>> >>>
>> >>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> >>
>> >> This is really strange.
>> >>
>> >> packet_length() subtracts VLAN_HLEN from the value it returns, so the
>> >> correct fix seems to be to make this function handle the PPPOE case
>> >> too.
>> >>
>> > 
>> > It is correct. The actual MTU of 802.1q frame is 4 bytes larger. For
>> > example, the MTU of ethernet is normally 1500, however the actual MTU
>> > of the 802.1Q is 1504.
>> 
>> Yes, I understand this, but I don't see why packet_length() cannot
>> simply account for PPPOE's encapsulation overhead just as it does for
>> VLAN's special MTU considerations.
> 
> Because PPPOE happens afterwards and is not part the calculation.
> The check should be moved until after skb has reached final form.

That works for me.
