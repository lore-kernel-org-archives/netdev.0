From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4 devices
Date: Sat, 09 Mar 2013 13:34:22 +0900
Message-ID: <513ABBCE.1090501@linux-ipv6.org>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com> <20130307204120.GA3808@x61s.8.8.8.8> <51394B32.9090807@linux-ipv6.org> <20130308093739.GB788@x61s.8.8.8.8> <513A203B.9030701@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49747 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760295Ab3CIEeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 23:34:24 -0500
In-Reply-To: <513A203B.9030701@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Alexander Aring wrote:
:
>> With your patch, which isn't working anymore:
>>
>> iphc0 = 7b, iphc1 = 3b
>> NH flag is set, next header carried inline: 3a
>> source address stateless compression
>> (lowpan_uncompress_addr) linklocal address: 
>> 02 85 00 3a 20 00 00 00
>> uncompressing 2 + 0 => 
>> fe 80 00 00 00 00 00 00 00 85 00 3a 20 00 00 00
>> dest: non context-based mcast compression
>> uncompressing 2 + 1 => 
>> ff 02 00 00 00 00 00 00 00 00 00 00 00 00 00 02
>> skb headroom size = 25, data length = 24
>> IPv6 header dump:
>> 	version = 6
>> 	length  = 24
>> 	nexthdr = 0x3a
>> 	hop_lim = 255
>>
>> And for every ipv6 packet I got:
>> ICMPv6 checksum failed [fe80:0000:0000:0000:0001:ff00:0001:8700 > ff02:0000:0000:0000:0000:0001:ff00:0001]
>>
>> I seems that the reconstructed destination address and header length are
>> not right.
> 
> That's wired.  It is expected to work whatever valid source/destination
> addesses are used, right?

It seems the last argument for lowpan_uncompress_address() (lladdr,
show as "linklocal address") is incorrect.
Note that it should say link-"layer" address, BTW.

--yoshfuji
