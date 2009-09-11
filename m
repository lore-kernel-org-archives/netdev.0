From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Fri, 11 Sep 2009 11:45:10 -0700 (PDT)
Message-ID: <510605.34044.qm@web111611.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>  <1252376168.5244.11.camel@dogo.mojatatu.com>  <313388.35529.qm@web111617.mail.gq1.yahoo.com>  <1252534266.4119.5.camel@dogo.mojatatu.com>  <204967.7557.qm@web111613.mail.gq1.yahoo.com> <1252671940.25158.5.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n6a.bullet.mail.ac4.yahoo.com ([76.13.13.69]:34345 "HELO
	n6a.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754699AbZIKSpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 14:45:08 -0400
In-Reply-To: <1252671940.25158.5.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I run your example ( mirror  lo -> eth0) on Sep. 10th, got almost the same result(in my last email) as yours.
I think interface 'lo' is very special.

When I do the following (eth0 -> lo), the results are very strange.
1> run 'tc qdisc add dev eth0 handle 1: root prio'

2>  tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
match ip src 192.168.1.0/32 flowid 1:16 \
action pedit munge offset -14 u16 set 0x0023 \
munge offset -12 u32 set 0xcdafecda \
munge offset -8 u32 set 0x0023cdaf \
munge offset -4 u32 set 0xd0740800 pipe \
action mirred egress mirror dev lo

window1  run ' ping 192.168.1.1'
window2  'tcpdump -i lo -e', I can not capture any packets.

mirror  lo -> eth0 ok, eth0 -> lo  can not work ???

2'> change 'action mirred egress mirror dev lo' to 'action mirred egress mirror dev eth1' ,
'tcpdump -i eth1 -e'    also capture nothing.
Does this mean something wrong with ' action pedit ...' ?   ("offset must be on 32 bit boundaries"?)

 
>> lo -> eth0
>> But I want to only modify the dst MAC, src MAC of the mirroring packets, transmit them to next hop. 
>> (not modify the dst,src MAC of the packets to 'lo').  What should I do?

>Ok, so modifying then mirroring wont work on ingress;->
>One thing you can try is first to mirror lo->eth0, then pedit only
>specific flow on eth0 that came from lo.

How to do this. Could you show me the example commands?   Thank you.


regards,
wu



      

