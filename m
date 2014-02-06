From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source
 addresses in ICMPv6 error messages
Date: Thu, 06 Feb 2014 10:37:07 +0100
Message-ID: <52F357C3.9060406@6wind.com>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:46726 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754961AbaBFJhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 04:37:21 -0500
Received: by mail-wi0-f178.google.com with SMTP id cc10so1374914wib.17
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 01:37:20 -0800 (PST)
In-Reply-To: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/01/2014 17:00, Francois-Xavier Le Bail a =C3=A9crit :
> - Uses ipv6_anycast_destination() in icmp6_send().
>
> Suggested-by: Bill Fink <billfink@mindspring.com>
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
This patch causes an Oops on my target.

Here is the step to reproduce it:
modprobe sit
ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
ip l s sit1 up
ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
ping6 2001:1234::121

The problem is that ipv6_anycast_destination() uses unconditionally
skb_dst(skb), which is NULL in this case.

Not sure what is the best way to fix this, any suggestions?


Regards,
Nicolas
