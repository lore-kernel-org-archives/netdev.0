From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: tc match MAC destination
Date: Wed, 15 Jun 2011 09:29:07 -0400
Message-ID: <20110615092907.2b79ee66@s6510.ftrdhcpuser.net>
References: <1308125523.30324.64.camel@ierdnac-hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pdoru.kernel@evox.ro,
	netdev@vger.kernel.org
To: ierdnah@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43758 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337Ab1FON3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 09:29:05 -0400
In-Reply-To: <1308125523.30324.64.camel@ierdnac-hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jun 2011 11:12:01 +0300
Andrei Popa <ierdnah@gmail.com> wrote:

> Hello,
> 
> I want to shape PVSTP+ traffic (traffic that has MAC destination
> 01:00:0c:cc:cc:cd) and it doesn't work.
> I've tried
> filter parent 1: protocol 802_3 pref 2 u32 fh 802::11 order 17 key ht
> 802 bkt 0 flowid 1:3 
>   match 01000ccc/ffffffff at 0
> but it doesn't work.
> 
> With
> filter parent 1: protocol arp pref 1 u32 
> filter parent 1: protocol arp pref 1 u32 fh 801: ht divisor 1 
> filter parent 1: protocol arp pref 1 u32 fh 801::7 order 7 key ht 801
> bkt 0 flowid 1:3 
>   match 00000000/00000000 at 0
> filter parent 1: protocol 802_3 pref 2 u32 
> filter parent 1: protocol 802_3 pref 2 u32 fh 802: ht divisor 1 
> filter parent 1: protocol 802_3 pref 2 u32 fh 802::3 order 3 key ht 802
> bkt 0 flowid 1:3 
>   match 00000000/00000000 at 0
>         action order 1: mirred (Egress Mirror to device ifb1) pipe
>         index 1923 ref 1 bind 1
> 
> I see arp trafic with tcpdump on ifb1, but no STP traffic or any kind of
> traffic except arp, because I've matched all MAC addreses.
> Can somebody verify that this match works ?
> 
> I use kernel 2.6.39.1.
> 
> Thank you,

If you use current iproute tools it is possible to use:
 tc filter ... match ether dst 01:00:0c:cc:cc:cd

which generates the necessary offset.
