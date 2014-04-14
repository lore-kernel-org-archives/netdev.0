From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: seccomp: fix wrong decoding of
 BPF_S_ANC_SECCOMP_LD_W
Date: Mon, 14 Apr 2014 16:47:53 -0400 (EDT)
Message-ID: <20140414.164753.1675305498861641361.davem@davemloft.net>
References: <1397503212-17087-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, xemul@parallels.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbaDNUr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 16:47:58 -0400
In-Reply-To: <1397503212-17087-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 14 Apr 2014 21:20:12 +0200

> While reviewing seccomp code, we found that BPF_S_ANC_SECCOMP_LD_W has
> been wrongly decoded by commit a8fc927780 ("sk-filter: Add ability to
> get socket filter program (v2)") into the opcode BPF_LD|BPF_B|BPF_ABS
> although it should have been decoded as BPF_LD|BPF_W|BPF_ABS.
> 
> In practice, this should not have much side-effect though, as such
> conversion is/was being done through prctl(2) PR_SET_SECCOMP. Reverse
> operation PR_GET_SECCOMP will only return the current seccomp mode, but
> not the filter itself. Since the transition to the new BPF infrastructure,
> it's also not used anymore, so we can simply remove this as it's
> unreachable.
> 
> Fixes: a8fc927780 ("sk-filter: Add ability to get socket filter program (v2)")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
