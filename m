From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4 devices
Date: Sat, 09 Mar 2013 02:30:35 +0900
Message-ID: <513A203B.9030701@linux-ipv6.org>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com> <20130307204120.GA3808@x61s.8.8.8.8> <51394B32.9090807@linux-ipv6.org> <20130308093739.GB788@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33811 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759799Ab3CHRah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:30:37 -0500
In-Reply-To: <20130308093739.GB788@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Aring wrote:
> Hi,
> 
> On Fri, Mar 08, 2013 at 11:21:38AM +0900, YOSHIFUJI Hideaki wrote:
>> Hi,
>>
>> Alexander Aring wrote:
>>> Hi,
>>>
>>> I don't know if this is a right solution for that, because other
>>> functions like addrconf_ifid_infiniband to manipulate eui after memcpy,
>>> too.
>>>
>>> But this patch solves my problems with ieee802154 stack.
>>
>> What kind of problems do you have?
>>
> 
> I compile with #define DEBUG enabled in net/ieee802154/6lowpan.c
> 
> The problem is the address compression in 6lowpan.
> 
> First device has address fe80::a000:0:0:1/64. Second device has address
> fe80::a000:0:0:2/64. I use only a ping6 to check connection.
> 
> Debug Information on the receiving side:
> Without your patch which is working.
> 
> iphc0 = 7a, iphc1 = 11
> NH flag is set, next header carried inline: 3a
> source address stateless compression
> (lowpan_uncompress_addr) linklocal address: 
> a0 00 00 00 00 00 00 02
> uncompressing 2 + 8 => 
> fe 80 00 00 00 00 00 00 a0 00 00 00 00 00 00 02
> dest: stateless compression
> (lowpan_uncompress_addr) linklocal address: 
> a0 00 00 00 00 00 00 01
> uncompressing 2 + 8 => 
> fe 80 00 00 00 00 00 00 a0 00 00 00 00 00 00 01
> skb headroom size = 40, data length = 64
> IPv6 header dump:
> 	version = 6
> 	length  = 64
> 	nexthdr = 0x3a
> 	hop_lim = 64
> 
> 
> With your patch, which isn't working anymore:
> 
> iphc0 = 7b, iphc1 = 3b
> NH flag is set, next header carried inline: 3a
> source address stateless compression
> (lowpan_uncompress_addr) linklocal address: 
> 02 85 00 3a 20 00 00 00
> uncompressing 2 + 0 => 
> fe 80 00 00 00 00 00 00 00 85 00 3a 20 00 00 00
> dest: non context-based mcast compression
> uncompressing 2 + 1 => 
> ff 02 00 00 00 00 00 00 00 00 00 00 00 00 00 02
> skb headroom size = 25, data length = 24
> IPv6 header dump:
> 	version = 6
> 	length  = 24
> 	nexthdr = 0x3a
> 	hop_lim = 255
> 
> And for every ipv6 packet I got:
> ICMPv6 checksum failed [fe80:0000:0000:0000:0001:ff00:0001:8700 > ff02:0000:0000:0000:0000:0001:ff00:0001]
> 
> I seems that the reconstructed destination address and header length are
> not right.

That's wired.  It is expected to work whatever valid source/destination
addresses are used, right?

--yoshfuji
