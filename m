From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix verifier memory corruption
Date: Wed, 15 Apr 2015 19:05:58 +0200
Message-ID: <552E9A76.9080006@iogearbox.net>
References: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56473 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755851AbbDORGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:06:05 -0400
In-Reply-To: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 12:57 AM, Alexei Starovoitov wrote:
> Due to missing bounds check the DAG pass of the BPF verifier can corrupt
> the memory which can cause random crashes during program loading:
>
> [8.449451] BUG: unable to handle kernel paging request at ffffffffffffffff
> [8.451293] IP: [<ffffffff811de33d>] kmem_cache_alloc_trace+0x8d/0x2f0
> [8.452329] Oops: 0000 [#1] SMP
> [8.452329] Call Trace:
> [8.452329]  [<ffffffff8116cc82>] bpf_check+0x852/0x2000
> [8.452329]  [<ffffffff8116b7e4>] bpf_prog_load+0x1e4/0x310
> [8.452329]  [<ffffffff811b190f>] ? might_fault+0x5f/0xb0
> [8.452329]  [<ffffffff8116c206>] SyS_bpf+0x806/0xa30
>
> Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

As far as I can tell, looks good to me. Any other access to a next
instruction elsewhere would be blocked from push_insn() with an error.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
