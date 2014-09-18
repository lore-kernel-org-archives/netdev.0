From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 06:41:29 -0700
Message-ID: <1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917152653.1c824a22@redhat.com>
	 <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5419A1E7.8040109@intel.com> <20140918085640.0815df6d@redhat.com>
	 <1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35414 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755159AbaIRNlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:41:31 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so1438678pdb.14
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 06:41:31 -0700 (PDT)
In-Reply-To: <1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 06:33 -0700, Eric Dumazet wrote:

> Note that for TCP, there are packets sent by the process doing the
> send(), or packets sent by cpu doing TX completion (because of TSQ),
> but also packets sent by ACK processing done in the reverse way.
> 
> As Alexander explained, if the ACK packets are delivered into another
> CPU, then you might select another TX queue.
> 
> This is mostly prevented because of ooo_okay logic, meaning that a busy
> bulk flow should stick into a single TX queue, no matter of XPS says.
> 
> A TCP_RR workload is free to chose whatever queue, because every packet
> starting a RR block has the ooo_okay set (As prior data was delivered
> and acknowledged by the opposite peer)
> 

Last but not least, there is the fact that networking stacks use
mod_timer() to arm timers, and that by default, timer migration is on 
( cf /proc/sys/kernel/timer_migration )

We probably should use mod_timer_pinned(), but I could not really see
any difference.
