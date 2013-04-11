From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: stop ip-config if disabled method directed
Date: Wed, 10 Apr 2013 23:19:35 -0400 (EDT)
Message-ID: <20130410.231935.1794061214116167901.davem@davemloft.net>
References: <5165138A.7070006@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: takashi.yoshii.zj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab3DKDTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 23:19:37 -0400
In-Reply-To: <5165138A.7070006@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Yoshii <takashi.yoshii.zj@renesas.com>
Date: Wed, 10 Apr 2013 16:23:54 +0900

> Looks insignificant, but a misusage of kernel level auto configuration
> results in an invalid ipv4 address set.
> That is a kind of corner case, but I think it is be better sanitizing
>  the input a bit more for our simple in_aton().
> --
> 
> CONFIG_IP_PNP=y
> CONFIG_IP_PNP_DHCP=n
> Command line: ip=dhcp
> result in false ip address 62.0.0.0 set.
> 
> If directed autoconf method is not compiled into the kernel,
> ip-config should be terminated.
> 
> Signed-off-by: Takashi Yoshii <takashi.yoshii.zj@renesas.com>

This is a poor submission.

When you put _before_ the "--" is the commit message, and the
text afterwards will be removed and not considered as part of
the commit message.

Secondly, put this logic into ic_proto_name() so we don't duplicate
all of these string comparisons.

Thirdly, consider simply removing all of these silly Kconfig
options, they seem rediculous.
