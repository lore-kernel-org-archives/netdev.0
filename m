From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 5/8] net/mlx5e: Calc vlan_tag_present only once on
 xmit
Date: Wed, 1 Feb 2017 11:20:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0277BF0@AcuExch.aculab.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-6-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:62098 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbdBALUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 06:20:15 -0500
In-Reply-To: <20170131205843.23235-6-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 31 January 2017 20:59
> Cache skb_vlan_tag_present(skb) and pass it wherever needed in xmit
> routines.
...

Does this actually generate better code?
It is quite likely that your 'vlan_present' variable ends up being on stack.
Whereas the 'skb' is likely to be in a register.
In which case the two loads are likely to be must the same and your
change has added a write to the stack.

	David
