From: jamal <hadi@cyberus.ca>
Subject: Re: tc match MAC destination
Date: Wed, 15 Jun 2011 10:51:52 -0400
Message-ID: <1308149512.14627.1.camel@mojatatu>
References: <1308125523.30324.64.camel@ierdnac-hp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pdoru.kernel@evox.ro, netdev@vger.kernel.org
To: ierdnah@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65101 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253Ab1FOOwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 10:52:05 -0400
Received: by fxm17 with SMTP id 17so455494fxm.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 07:52:04 -0700 (PDT)
In-Reply-To: <1308125523.30324.64.camel@ierdnac-hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-06-15 at 11:12 +0300, Andrei Popa wrote:
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

MAC addresses are at -ve offsets.
dst MAC starts at -14
src MAC at -8
ethertype at -2

Example:
#match my laptops MAC address ( 00:0b:97:97:4d:6a)
#for incoming packets on eth0 and count arp packets...
#
tc filter add dev eth0 parent ffff: protocol arp prio 10 u32 \
match u16 0x000B 0xffff at -14 \
match u32 0x97974D6A 0xffffffff at -12 \
match u16 0x0806 0xffff at -2 \
flowid 1:12 \
action ok

cheers,
jamal



