From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: DSA and underlying 802.1Q encapsulation
Date: Tue, 26 May 2015 18:29:57 -0400 (EDT)
Message-ID: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:58611 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbEZWaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 18:30:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm doing tests with VLAN support in DSA and I noticed that the EDSA 
frame is prepended with a 802.1q header once queued to the underlying 
network device, in net/dsa/tag_edsa.c:

    skb->dev = p->parent->dst->master_netdev;
    dev_queue_xmit(skb);

This issue can be observed with the following dump:

    curl -s http://ix.io/iIv | tcpdump -en -r -

I suspect that the DSA code must clear some VLAN flags in the skb
structure, in order to prevent the additional encapsulation by the lower
level. Does this make sense?

Thanks,
-v
