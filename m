From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: avoid copying junk bytes in
 bpf_get_current_comm()
Date: Wed, 09 Mar 2016 23:28:12 -0500 (EST)
Message-ID: <20160309.232812.952849846092100551.davem@davemloft.net>
References: <1457582553-395600-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tobias@waldekranz.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906AbcCJE2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 23:28:15 -0500
In-Reply-To: <1457582553-395600-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 9 Mar 2016 20:02:33 -0800

> Lots of places in the kernel use memcpy(buf, comm, TASK_COMM_LEN); but
> the result is typically passed to print("%s", buf) and extra bytes
> after zero don't cause any harm.
> In bpf the result of bpf_get_current_comm() is used as the part of
> map key and was causing spurious hash map mismatches.
> Use strlcpy() to guarantee zero-terminated string.
> bpf verifier checks that output buffer is zero-initialized,
> so even for short task names the output buffer don't have junk bytes.
> Note it's not a security concern, since kprobe+bpf is root only.
> 
> Fixes: ffeedafbf023 ("bpf: introduce current->pid, tgid, uid, gid, comm accessors")
> Reported-by: Tobias Waldekranz <tobias@waldekranz.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> Targeting net-next, since it's too late for net.
> I think it makes sense for stable as well.

Applied and queued up for -stable, thanks.
