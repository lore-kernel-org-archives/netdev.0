From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sun, 18 Dec 2011 10:13:29 -0500
Message-ID: <4EEE0319.3050305@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <20111217.215630.640392276998191183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:58505 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751264Ab1LRPNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 10:13:53 -0500
In-Reply-To: <20111217.215630.640392276998191183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2011 21:56, David Miller wrote:


>> +		netdev_for_each_mc_addr(ha, dev)
>> +			set_bit((ether_crc(ETH_ALEN, ha->addr) >> 26),
>> +				    (volatile long unsigned int *)&priv->mcast_filter);
> 
> This makes an assumption not only about the size of the "unsigned long"
> type, but also of the endianness of the architecture this runs on.
> 


Can you give me some tips on this one?  au1000_eth.c does the same thing,
and I'm not seeing what the endian issue is exactly.  Is it the >> 26 part
or the use of ether_crc?  I see there's an ether_crc_le, too, and some
drivers also do the >> 26 bit on it as well.

Which is correct?  The few drivers I've looked at don't exactly spell out
this part of the code, and are usually doing something different because
most seem to access the multicast filter register in either 8-bits or
32-bits.  MACE ethernet seems to be one of the few doing it in full 64-bits.


Thanks,

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
