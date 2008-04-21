From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] nf_nat_proto_sctp.c:(.text+0x6d173): undefined
 reference to `crc32c_le'
Date: Sun, 20 Apr 2008 23:53:54 -0700 (PDT)
Message-ID: <20080420.235354.104901823.davem@davemloft.net>
References: <20080421062244.GA862@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45330
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYDUGxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 02:53:52 -0400
In-Reply-To: <20080421062244.GA862@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Apr 2008 08:22:44 +0200

>   net/built-in.o: In function `sctp_manip_pkt':
>   nf_nat_proto_sctp.c:(.text+0x6d173): undefined reference to `crc32c_le'
>   nf_nat_proto_sctp.c:(.text+0x6d180): undefined reference to `crc32c_le'
>   nf_nat_proto_sctp.c:(.text+0x6d196): undefined reference to `crc32c_le'
>   nf_nat_proto_sctp.c:(.text+0x6d1c6): undefined reference to `crc32c_le'
> 
>   http://redhat.com/~mingo/misc/config-Mon_Apr_21_01_52_14_CEST_2008.bad

Thanks for your report Ingo.

Patrick, I'm not so sure how to fix this, or even what's wrong.

NF_NAT_PROTO_SCTP does a proper select on LIBCRC32C, but somehow
NF_NAT_PROTO_SCTP=y and LIBCRC32C=m.

I notice that IP_SCTP=m in this config.  So perhaps the issue is the
case where two features do a select on an infrastructure config
option.  Maybe whoever does the last 'select' gets to decide if the
option gets set to 'y' or 'm'?

It's just a guess, as I still for the life of me can't figure out
how these dependencies get sorted by the kbuild system in situations
like this.

