From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock, diag: fix panic in sock_diag_put_filterinfo
Date: Wed, 02 Sep 2015 11:31:22 -0700 (PDT)
Message-ID: <20150902.113122.471880367561328606.davem@davemloft.net>
References: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754958AbbIBSbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:31:23 -0400
In-Reply-To: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  2 Sep 2015 14:00:36 +0200

> diag socket's sock_diag_put_filterinfo() dumps classic BPF programs
> upon request to user space (ss -0 -b). However, native eBPF programs
> attached to sockets (SO_ATTACH_BPF) cannot be dumped with this method:
> 
> Their orig_prog is always NULL. However, sock_diag_put_filterinfo()
> unconditionally tries to access its filter length resp. wants to copy
> the filter insns from there. Internal cBPF to eBPF transformations
> attached to sockets don't have this issue, as orig_prog state is kept.
> 
> It's currently only used by packet sockets. If we would want to add
> native eBPF support in the future, this needs to be done through
> a different attribute than PACKET_DIAG_FILTER to not confuse possible
> user space disassemblers that work on diag data.
> 
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks.
