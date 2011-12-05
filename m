From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: eth0: hw csum failure
Date: Mon, 5 Dec 2011 08:17:41 -0800
Message-ID: <20111205081741.738af1c0@nehalam.linuxnetplumber.net>
References: <201112051351.26798.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pavel Mateja <pavel@netsafe.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37877 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932447Ab1LEQRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 11:17:44 -0500
In-Reply-To: <201112051351.26798.pavel@netsafe.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If i did git bisect right it was caused by commit
> 4b275d7efa1c4412f0d572fcd7f78ed0919370b3
> bridge: Pseudo-header required for the checksum of ICMPv6
> 
> Problem disappears when I turn off HW checksum via ethtool.
> 
> Can anybody help?

Fixed in 3.1 (and queued for 3.0 stable).

commit fa2da8cdae1dd64f78fc915ca1d1a4a93c71e7cb
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Tue Nov 15 08:09:14 2011 +0000

    bridge: correct IPv6 checksum after pull
    
    Bridge multicast snooping of ICMPv6 would incorrectly report a checksum prob
    when used with Ethernet devices like sky2 that use CHECKSUM_COMPLETE.
    When bytes are removed from skb, the computed checksum needs to be adjusted.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Tested-by: Martin Volf <martin.volf.42@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
