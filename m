From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Mon, 07 Sep 2009 22:16:08 -0400
Message-ID: <1252376168.5244.11.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.221.181]:49464 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbZIHCSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 22:18:32 -0400
Received: by qyk11 with SMTP id 11so2430642qyk.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 19:18:33 -0700 (PDT)
In-Reply-To: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-07 at 09:05 -0700, Xiaofei Wu wrote:

> (1) Could I use  pedit action to modify the dst MAC, so the destination node D will accept it, 
> then forward it to node C?  

Yes, you can achieve it with pedit; 


> (or use other tools to modify the dst MAC, please give me more information)
> 

it is as usable as u32 is - you have to know your offsets
example, here's something done on an incoming packet:
=-=
#Note:
#dst MAC starts at -14
#src MAC at -8
#ethertype at -2
#
tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 \
match ip src 192.168.2.11/32 flowid 1:2 \
action pedit munge offset -14 u16 set 0x0000 \
munge offset -12 u32 set 0x00000200 \
munge offset -8 u32 set 0x0aaf0100 \
munge offset -4 u32 set 0x0008eb06 pipe \
action mirred egress redirect dev eth0
----

> (2) If I use 'ifconfig wlan0 promisc ... ' on node D, would it route the mirroring packets
>  (the dst MAC is incorrect)
> to node C?

It may work.
Go and try running some experiments.

cheers,
jamal

