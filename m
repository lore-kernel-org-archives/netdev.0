From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [IPV6]: Consolidate common SNMP code
Date: Tue, 24 Apr 2007 22:12:39 -0700 (PDT)
Message-ID: <20070424.221239.00772916.davem@davemloft.net>
References: <20070425040637.GA4838@gondor.apana.org.au>
	<20070425.132103.129791594.yoshfuji@linux-ipv6.org>
	<20070424.215429.42460618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161608AbXDYFMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 01:12:32 -0400
In-Reply-To: <20070424.215429.42460618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 24 Apr 2007 21:54:29 -0700 (PDT)

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Wed, 25 Apr 2007 13:21:03 +0900 (JST)
> 
> > In article <20070425040637.GA4838@gondor.apana.org.au> (at Wed, 25 Apr 2007 14:06:37 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> > 
> > > Hi:
> > > 
> > > [IPV6]: Consolidate common SNMP code
> > > 
> > > This patch moves the non-proc SNMP code into addrconf.c and reuses
> > > IPv4 SNMP code where applicable.
> > :
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > 
> > Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Also applied, thanks.

This breaks the build with IPV6 modular:

  LD      .tmp_vmlinux1
net/built-in.o: In function `snmp6_seq_show':
proc.c:(.text+0x68244): undefined reference to `ipv6_statistics'
proc.c:(.text+0x68250): undefined reference to `ipv6_statistics'
proc.c:(.text+0x68284): undefined reference to `icmpv6_statistics'
proc.c:(.text+0x68288): undefined reference to `icmpv6_statistics'
proc.c:(.text+0x682c8): undefined reference to `udp_stats_in6'
proc.c:(.text+0x682cc): undefined reference to `udp_stats_in6'
proc.c:(.text+0x6830c): undefined reference to `udplite_stats_in6'
proc.c:(.text+0x68310): undefined reference to `udplite_stats_in6'
net/built-in.o: In function `sockstat6_seq_show':
proc.c:(.text+0x68360): undefined reference to `tcpv6_prot'
proc.c:(.text+0x68368): undefined reference to `tcpv6_prot'
proc.c:(.text+0x68380): undefined reference to `udpv6_prot'
proc.c:(.text+0x68388): undefined reference to `udpv6_prot'
proc.c:(.text+0x68398): undefined reference to `udplitev6_prot'
proc.c:(.text+0x683a0): undefined reference to `udplitev6_prot'
proc.c:(.text+0x683b0): undefined reference to `rawv6_prot'
proc.c:(.text+0x683b8): undefined reference to `rawv6_prot'
proc.c:(.text+0x683c8): undefined reference to `ip6_frag_nqueues'
proc.c:(.text+0x683d0): undefined reference to `ip6_frag_nqueues'
proc.c:(.text+0x683d4): undefined reference to `ip6_frag_mem'
proc.c:(.text+0x683dc): undefined reference to `ip6_frag_mem'
make: *** [.tmp_vmlinux1] Error 1
