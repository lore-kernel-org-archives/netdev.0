From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq
 network code on SMP
Date: Thu, 20 Sep 2007 10:46:14 -0700 (PDT)
Message-ID: <20070920.104614.58454013.davem@davemloft.net>
References: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de
To: johny@asimco.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38076
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752046AbXITRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 13:46:14 -0400
In-Reply-To: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The whole reason the queues are per-cpu is so that we do not
have to touch remote processor state nor use locks of any
kind whatsoever.

With multi-queue networking cards becoming more and more
available, which will split up the packet workload in
hardware across all available cpus, there is less and less
reason to make a patch like this one.

We've known about this issue for ages, and if we felt it
was appropriate to make this change, we would have done
so years ago.
