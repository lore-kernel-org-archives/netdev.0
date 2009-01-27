From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 14:43:20 -0800
Message-ID: <497F8E08.6040303@hp.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net>	<497F4C2F.9000804@hp.com>	<497F5BCD.9060807@hp.com>	<497F5F86.9010101@hp.com>	<497F87E7.2000304@cosmosbay.com> <497F8ACD.2050203@hp.com> <497F8BDA.6080908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:22693 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbZA0WnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 17:43:24 -0500
In-Reply-To: <497F8BDA.6080908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> By any chance, are you using SLAB instead of SLUB ?

Seems that way:

sut42:~/net-next-2.6# grep SLAB .config
CONFIG_SLAB=y
CONFIG_SLABINFO=y
# CONFIG_DEBUG_SLAB is not set
sut42:~/net-next-2.6# grep SLUB .config
# CONFIG_SLUB is not set

The config file should be up under the base URL:

ftp://ftp.netperf.org/iptable_scaling

The system started as a Debian Lenny with a 2.6.26 kernel, and I did a make old 
config and mostly took defaults (save multiq)


> While running your netperf session, issuing :
> 
> grep conntrack /proc/slabinfo
> 
> Would help to know hash dispertion on your machine.


sut42:~/net-next-2.6# grep conntrack /proc/slabinfo
nf_conntrack_expect      0      0    240   66    1 : tunables  120   60    8 : 
slabdata      0      0      0
nf_conntrack         276    742    304   53    1 : tunables   54   27    8 : 
slabdata     14     14      0

about a minute later it is:

grep conntrack /proc/slabinfo
nf_conntrack_expect      0      0    240   66    1 : tunables  120   60    8 : 
slabdata      0      0      0
nf_conntrack         315    742    304   53    1 : tunables   54   27    8 : 
slabdata     14     14      0

after about another 40 to 60 seconds it was:

grep conntrack /proc/slabinfo
nf_conntrack_expect      0      0    240   66    1 : tunables  120   60    8 : 
slabdata      0      0      0
nf_conntrack         314    742    304   53    1 : tunables   54   27    8 : 
slabdata     14     14      7

