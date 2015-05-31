From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add missing rcu protection when
 releasing programs from prog_array
Date: Sun, 31 May 2015 00:28:01 -0700 (PDT)
Message-ID: <20150531.002801.2081582008644330193.davem@davemloft.net>
References: <1432866362-8154-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, holzheu@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbEaH2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 03:28:03 -0400
In-Reply-To: <1432866362-8154-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 28 May 2015 19:26:02 -0700

> Normally the program attachment place (like sockets, qdiscs) takes
> care of rcu protection and calls bpf_prog_put() after a grace period.
> The programs stored inside prog_array may not be attached anywhere,
> so prog_array needs to take care of preserving rcu protection.
> Otherwise bpf_tail_call() will race with bpf_prog_put().
> To solve that introduce bpf_prog_put_rcu() helper function and use
> it in 3 places where unattached program can decrement refcnt:
> closing program fd, deleting/replacing program in prog_array.
> 
> Fixes: 04fd61ab36ec ("bpf: allow bpf programs to tail-call other bpf programs")
> Reported-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thank you.
