From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sun, 23 Dec 2012 12:13:03 +0100
Message-ID: <50D6E73F.70301@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:60228 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab2LWLNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 06:13:10 -0500
Received: by mail-bk0-f52.google.com with SMTP id w5so3021044bku.11
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 03:13:09 -0800 (PST)
In-Reply-To: <50D6BF6F.2030207@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> net/ipv6/ndisc.c SHOULD build full NDP messages for IPv6
> over IEEE1394 as we do it for Infiniband.
>
> Please, please do not try to mangle them in the driver.
>
As far as I understand the code for Infiniband (and the corresponding 
RFC4391) I just see the introduction of two pad bytes. Moreover, I see 
that ndisc_build_skb calls ndisc_fill_addr_option which copies 
dev->dev_addr. Maybe the so called Queue Pair Number (QPN) is already 
included in dev->dev_addr. If not, I guess the Infiniband driver will 
also mangle the QPN into the link layer option. If not, this seems only 
possible because the format for IPv6 link layer option (IB) and IPv4/ARP 
(IB) has the same format.

This is not true IPv4/ARP and IPv6 link layer option for firewire. 
Moreover, firewire link layer address mapping (IPv4 and IPv6) requires 
some very firewire specific information like speed, max_rec and 
especially the so called unicast fifo address.

 From my point of view the generic ndisc code shall not cope with these 
nasty details of the specific link layers. I also haven't found a driver 
specific hook that might fill these information in. That's why I think I 
_have_ to mangle the NDP stuff in the driver.

Stephan
