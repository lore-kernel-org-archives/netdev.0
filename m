From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Fri, 03 Jul 2015 18:39:13 +0200
Message-ID: <1435941553.11970.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1435770389.12101.110.camel@perches.com>
	 <1435788837.8526.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB5BCAC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Nicolae Rosia <nicolae.rosia@certsign.ro>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	'Nicolas Ferre <nicolas.ferre@atmel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36254 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814AbbGCQjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:39:18 -0400
Received: by widjy10 with SMTP id jy10so114090625wid.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 09:39:17 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB5BCAC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-03 at 16:18 +0000, David Laight wrote:

> Even on x86 aligning the ethernet receive data on a 4n+2
> boundary is likely to give marginally better performance
> than aligning on a 4n boundary.

You are coming late to the party.

Intel guys decided to change NET_IP_ALIGN to 0 (it was 2 in the past)

commit ea812ca1b06113597adcd8e70c0f84a413d97544
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Tue Jun 29 18:38:00 2010 +0000

    x86: Align skb w/ start of cacheline on newer core 2/Xeon Arch
    
    x86 architectures can handle unaligned accesses in hardware, and it has
    been shown that unaligned DMA accesses can be expensive on Nehalem
    architectures.  As such we should overwrite NET_IP_ALIGN to resolve
    this issue.
    
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Ingo Molnar <mingo@redhat.com>
    Cc: "H. Peter Anvin" <hpa@zytor.com>
    Cc: x86@kernel.org
    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Acked-by: H. Peter Anvin <hpa@zytor.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
