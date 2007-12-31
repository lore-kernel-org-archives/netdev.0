From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Mon, 31 Dec 2007 04:13:42 -0800 (PST)
Message-ID: <20071231.041342.101160102.davem@davemloft.net>
References: <47775E7A.60708@redhat.com>
	<20071231.001925.151533664.davem@davemloft.net>
	<4778AE48.1040701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759387AbXLaMNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 07:13:44 -0500
In-Reply-To: <4778AE48.1040701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 31 Dec 2007 09:54:32 +0100

> Maybe I read the patch incorrectly, or we could add some new sysctl so that
> we not try to uncharge memory if a socket 'forward_alloc' is beyond a given 
> limit (say 2 pages), so that number of atomic_inc/dec on udp_memory_allocated 
> (or tcp_memory_allocated) is reduced.

This is what we should be striving for, using forward_alloc
as much as possible as a "cache" to avoid the atomics on
the global var as much as possible.
