From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: ptp: move PTP classifier in its own file
Date: Tue, 01 Apr 2014 16:43:37 -0400 (EDT)
Message-ID: <20140401.164337.2156139055557414655.davem@redhat.com>
References: <1396362023-8704-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, ast@plumgrid.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org, jbenc@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbaDAUnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 16:43:45 -0400
In-Reply-To: <1396362023-8704-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  1 Apr 2014 16:20:23 +0200

> This commit fixes a build error reported by Fengguang, that is
> triggered when CONFIG_NETWORK_PHY_TIMESTAMPING is not set:
> 
>   ERROR: "ptp_classify_raw" [drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.ko] undefined!
> 
> The fix is to introduce its own file for the PTP BPF classifier,
> so that PTP_1588_CLOCK and/or NETWORK_PHY_TIMESTAMPING can select
> it independently from each other. IXP4xx driver on ARM needs to
> select it as well since it does not seem to select PTP_1588_CLOCK
> or similar that would pull it in automatically.
> 
> This also allows for hiding all of the internals of the BPF PTP
> program inside that file, and only exporting relevant API bits
> to drivers.
> 
> This patch also adds a kdoc documentation of ptp_classify_raw()
> API to make it clear that it can return PTP_CLASS_* defines. Also,
> the BPF program has been translated into bpf_asm code, so that it
> can be more easily read and altered (extensively documented in [1]).
> 
> In the kernel tree under tools/net/ we have bpf_asm and bpf_dbg
> tools, so the commented program can simply be translated via
> `./bpf_asm -c prog` where prog is a file that contains the
> commented code. This makes it easily readable/verifiable and when
> there's a need to change something, jump offsets etc do not need
> to be replaced manually which can be very error prone. Instead,
> a newly translated version via bpf_asm can simply replace the old
> code. I have checked opcode diffs before/after and it's the very
> same filter.
> 
>   [1] Documentation/networking/filter.txt
> 
> Fixes: 164d8c666521 ("net: ptp: do not reimplement PTP/BPF classifier")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Looks good, applied, thanks Daniel.
