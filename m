From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Permit users to change transmit and receive max
 pachet size
Date: Mon, 03 Aug 2015 00:45:06 -0700 (PDT)
Message-ID: <20150803.004506.1774857049576413752.davem@davemloft.net>
References: <1438586918-12689-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbbHCHpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 03:45:10 -0400
In-Reply-To: <1438586918-12689-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Mon,  3 Aug 2015 10:28:38 +0300

>  Realtek nic its very versatile and have more registers for
>  optimise  and solve different issues.  I added 2 parameters rx_buf_sz and
>  txpacketmax  1.Parameter rx_buf_sz represent Receive Packet Maximum size and
>  on   this program is 16383 bytes, eg RTL 8101E use 16000 and user may use  
>  alls values up to maximum but value great from zero.   If a received packet
>  of packet length larger than the value set here, then it will set  both RWT
>  and RES bits in the corresponding Rx Status Descriptor. If the packet,  which
>  is larger than the RMS value, is received without CRC error, it is still a
>  good  packet, although both RWT and RES bits are set in the corresponding Rx
>  Status  Descriptor.  2. Parameter txpacketmax represent Max Transmit Packet
>  Size value must be on  range 1-63.Do not put zero on any situation.Every
>  field from range 1-63 have  128 bytes.  For regular LAN applications, i.e.,
>  the max packet size is either 1518 or 1522 (VLAN) bytes, this field must be
>  larger than the max packet size. E.g., 0x0C. On mee working good with
>  txpacketmax=60 and rx_buf_sz=1600
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

Sorry, such module parameters are completely inappropriate.

Control the values, at run time, using a standard, generic facility
such as ethtool.

Please stop sending patches that add new module parameters, they are
almost certainly guaranteed to be unacceptable.
