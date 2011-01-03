From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: bridge: check the length of skb after nf_bridge_maybe_copy_header()
Date: Mon, 3 Jan 2011 18:44:59 +0800
Message-ID: <AANLkTingFk8qJ8tBwSRCxD=9k-0O3GnTv9V9TbF4N=bg@mail.gmail.com>
References: <1293284490-17114-1-git-send-email-xiaosuo@gmail.com> <20101231.111003.48499853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44445 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1ACKpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 05:45:21 -0500
Received: by fxm20 with SMTP id 20so13081176fxm.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 02:45:20 -0800 (PST)
In-Reply-To: <20101231.111003.48499853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 1, 2011 at 3:10 AM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Sat, 25 Dec 2010 21:41:30 +0800
>
>> Since nf_bridge_maybe_copy_header() may change the length of skb,
>> we should check the length of skb after it to handle the ppoe skbs.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> This is really strange.
>
> packet_length() subtracts VLAN_HLEN from the value it returns, so the
> correct fix seems to be to make this function handle the PPPOE case
> too.
>

It is correct. The actual MTU of 802.1q frame is 4 bytes larger. For
example, the MTU of ethernet is normally 1500, however the actual MTU
of the 802.1Q is 1504.

Please see this patch:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=c893b8066c7bf6156e4d760e5acaf4c148e37190;hp=3c0fef0b7d36e5f8d3ea3731a8228102274e3c23

> Otherwise I suspect you have many other functions to fix as well.
>
> I'm not applying this patch.
>



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
