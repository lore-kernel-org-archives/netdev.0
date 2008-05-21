From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc"  to sch_netem
 module are not interpreted correctly
Date: Wed, 21 May 2008 15:36:39 -0700
Message-ID: <4834A3F7.4050807@hp.com>
References: <20080521214523.GB22591@codemonkey.org.uk> <48349F37.60709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@codemonkey.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:25655 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604AbYEUWgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 18:36:43 -0400
In-Reply-To: <48349F37.60709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

However, the message is not emitted if one compiles 
src/netrt_rtnetlink.c for standalone debug:

cc -otestfoo -DNETPERF_STANDALONE_DEBUG netrt_rtnetlink.c


izzy:~/netperf2_trunk# ./testfoo 16.89.133.212
address is 16.89.133.212
egress interface 0x6000000000004010 eth6


The one difference I see in that case is that the source IP is not 
passed-in, and in the full-up netperf omni case it is.  To confirm that 
I modified the -DNETPERF_STANDALONE_DEBUG part to take an optional parm 
for the source IP, and sure enough, I can get the netlink message that 
way with the standalone version:

izzy:~/netperf2_trunk# ./testfoo 16.89.133.212
destination address is 16.89.133.212
egress interface 0x6000000000004010 eth6
izzy:~/netperf2_trunk# ./testfoo 16.89.133.212 10.208.0.17
netlink: 8 bytes leftover after parsing attributes.
destination address is 16.89.133.212
egress interface 0x6000000000004010 eth6
izzy:~/netperf2_trunk# uname -a
Linux izzy 2.6.26-rc1-raj #1 SMP Thu May 8 15:24:23 PDT 2008 ia64 GNU/Linux

http://www.netperf.org/svn/netperf2/trunk/src/netrt_rtnetlink.c

fwiw,

rick jones
