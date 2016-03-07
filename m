From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/9] bpf: prevent kprobe+bpf deadlocks
Date: Mon, 07 Mar 2016 11:07:44 +0100
Message-ID: <56DD52F0.1060604@iogearbox.net>
References: <1457315917-1970307-1-git-send-email-ast@fb.com> <1457315917-1970307-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60668 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbcCGKHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 05:07:55 -0500
In-Reply-To: <1457315917-1970307-2-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2016 02:58 AM, Alexei Starovoitov wrote:
> if kprobe is placed within update or delete hash map helpers
> that hold bucket spin lock and triggered bpf program is trying to
> grab the spinlock for the same bucket on the same cpu, it will
> deadlock.
> Fix it by extending existing recursion prevention mechanism.
>
> Note, map_lookup and other tracing helpers don't have this problem,
> since they don't hold any locks and don't modify global data.
> bpf_trace_printk has its own recursive check and ok as well.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

LGTM

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
