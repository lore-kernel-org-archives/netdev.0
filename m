From: Shirley Ma <mashirle@us.ibm.com>
Subject: IPv6 MIB:ipv6PrefixTable implementation
Date: Wed, 19 Nov 2003 16:21:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311191621.38087.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, Alexy,

A while ago, we had a discussion about IPv6 Prefix Table implementation. 
I agree with you it's not necessary to process offlink prefix.

In each ipv6PrefixTable, there are 9 objects, which are Ifindex, Type, Prefix, 
Length, Origin(addrconf, manually, dhcp, others), OnLinkFlag, AutonomoueFlag, 
AdvPreferredLiftTime and ValidLifeTime. 

As we know, the routing table has all on-link prefix routes. But only Prefix,
Length, Ifindex are saved in routing table, the rest objects info are not saved
anywhere.

One implementation detail question, do you think I need to save all the other 
Prefix Objects: Type, Origin(addrconf, manually, dhcp, others), OnLinkFlag, 
AutonomoueFlag, AdvPreferredLiftTime and ValidLifeTime in routing table also?
If so, sounds like I add a big structure in each prefix route entry in the routing table.

Thanks
Shirley Ma

IBM Linux Technology Center
=======================



List:     linux-netdev
Subject:  Re: [Issues] Implementation for IPv6 MIB:ipv6PrefixTable
From:     kuznet () ms2 ! inr ! ac ! ru
Date:     2003-10-24 17:59:27

Hello!

> First, do you think it's a good idea to save all prefix objects in routing
> table?

Those which are on-link, of course.


> Second, where is the best location for the off-link prefix, on-link flag 0
> prefix to be saved?

Do you really think off-link prefixes are to be saved? Prefix in use is onlink
by defintion, so just return 1 in these bit and ignore off-link prefixes
completely, they are meaningless, are not they?


> Third, do you think it's a good idea to implement a prefix table/per
> interface in the kernel?

Well, if SNMP is going to be used as a tool to snoop ndisc promiscuously
(which seems to be the case if it shows inforrmation about offlink prefixes),
then it is definitely not a kernel task.

Alexey
