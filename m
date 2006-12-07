From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] memory barrier cleanups
Date: Wed, 06 Dec 2006 16:47:29 -0800 (PST)
Message-ID: <20061206.164729.41652274.davem@davemloft.net>
References: <20061206214946.GA22159@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937862AbWLGArS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:47:18 -0500
To: ralf@linux-mips.org
In-Reply-To: <20061206214946.GA22159@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 6 Dec 2006 21:49:46 +0000

> I believe all the below memory barriers only matter on SMP so therefore
> the smp_* variant of the barrier should be used.
> 
> I'm wondering if the barrier in net/ipv4/inet_timewait_sock.c should be
> dropped entirely.  schedule_work's implementation currently implies a
> memory barrier and I think sane semantics of schedule_work() should imply
> a memory barrier, as needed so the caller shouldn't have to worry.
> It's not quite obvious why the barrier in net/packet/af_packet.c is
> needed; maybe it should be implied through flush_dcache_page?
> 

I'll check out that timewait sock case later, but AF_PACKET mmap() is
totally broken on D-cache aliasing architectures.  Many years ago
I tried to fix this up with Alexey but those talks went nowhere :)

