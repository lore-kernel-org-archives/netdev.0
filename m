From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/9] bpf: introduce percpu_freelist
Date: Mon, 07 Mar 2016 11:33:38 +0100
Message-ID: <56DD5902.3000801@iogearbox.net>
References: <1457315917-1970307-1-git-send-email-ast@fb.com> <1457315917-1970307-3-git-send-email-ast@fb.com>
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
Received: from www62.your-server.de ([213.133.104.62]:35609 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcCGKdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 05:33:50 -0500
In-Reply-To: <1457315917-1970307-3-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2016 02:58 AM, Alexei Starovoitov wrote:
> Introduce simple percpu_freelist to keep single list of elements
> spread across per-cpu singly linked lists.
>
> /* push element into the list */
> void pcpu_freelist_push(struct pcpu_freelist *, struct pcpu_freelist_node *);
>
> /* pop element from the list */
> struct pcpu_freelist_node *pcpu_freelist_pop(struct pcpu_freelist *);
>
> The object is pushed to the current cpu list.
> Pop first trying to get the object from the current cpu list,
> if it's empty goes to the neigbour cpu list.
>
> For bpf program usage pattern the collision rate is very low,
> since programs push and pop the objects typically on the same cpu.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

These bits and their usage in combination with preallocation of objects
in patch 3/9 look very useful to me!

This code seems generic enough and doesn't contain any BPF specifics,
other subsystems could potentially utilize it as well, I'd suggest that
this should better be placed under lib/ so it's exposed/visible for other
developers too.

You can still add 'F:' entries into the MAINTAINERS file to make sure
patches also hit netdev:

BPF (Safe dynamic programs and tools)
[...]
F:	kernel/bpf/
F:      lib/percpu_freelist.c
F:      include/linux/percpu_freelist.h

When BPF_SYSCALL is enabled, it would then just select these library bits
via Kconfig. The lib bits themselves can be a hidden Kconfig entry.

Thanks,
Daniel
