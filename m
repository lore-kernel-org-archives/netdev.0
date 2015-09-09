From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ebpf: fix fd refcount leaks related to maps in bpf
 syscall
Date: Wed, 09 Sep 2015 12:39:52 -0700 (PDT)
Message-ID: <20150909.123952.1280382713842950863.davem@davemloft.net>
References: <021e4aac946ab776e7f4af1310f7ed2a642ccd08.1441727453.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbbIITjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:39:53 -0400
In-Reply-To: <021e4aac946ab776e7f4af1310f7ed2a642ccd08.1441727453.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  8 Sep 2015 18:00:09 +0200

> We may already have gotten a proper fd struct through fdget(), so
> whenever we return at the end of an map operation, we need to call
> fdput(). However, each map operation from syscall side first probes
> CHECK_ATTR() to verify that unused fields in the bpf_attr union are
> zero.
> 
> In case of malformed input, we return with error, but the lookup to
> the map_fd was already performed at that time, so that we return
> without an corresponding fdput(). Fix it by performing an fdget()
> only right before bpf_map_get(). The fdget() invocation on maps in
> the verifier is not affected.
> 
> Fixes: db20fd2b0108 ("bpf: add lookup/update/delete/iterate methods to BPF maps")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks Daniel.
