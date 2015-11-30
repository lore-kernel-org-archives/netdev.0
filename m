From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and integer
 overflow
Date: Mon, 30 Nov 2015 15:13:47 +0100
Message-ID: <565C599B.1020902@iogearbox.net>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com> <20151130005934.GA95228@ast-mbp.thefacebook.com> <565C549C.5080408@iogearbox.net> <CACT4Y+aGR2p6VCLgqg5otFU+0unPGp4rYe9jyCGLL1hg8D5_vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aGR2p6VCLgqg5otFU+0unPGp4rYe9jyCGLL1hg8D5_vA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2015 02:57 PM, Dmitry Vyukov wrote:
...
> kamlloc produces a WARNING if you try to allocate more than it ever
> possibly can (KMALLOC_SHIFT_MAX).

Sure, I understand that.

The kzalloc() in array_map_alloc() is however with __GFP_NOWARN flag already.
The warning only triggers in mm if:

   WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));

Your test case is using ca.map_type = 1, which is BPF_MAP_TYPE_HASH. So on
update you're triggering the kmalloc() in htab_map_update_elem().

I'm just asking about the added change in array map.

Thanks,
Daniel
