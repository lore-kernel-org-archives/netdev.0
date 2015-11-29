From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: user-controllable kmalloc size in bpf syscall
Date: Sun, 29 Nov 2015 10:21:50 -0800
Message-ID: <20151129182149.GA79352@ast-mbp.thefacebook.com>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>, daniel@iogearbox.net
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 29, 2015 at 02:18:29PM +0100, Dmitry Vyukov wrote:
>         ca.key_size = 1;
>         ca.value_size = 0xfffffff9;
>         ca.max_entries = 10;
>         int fd = syscall(SYS_bpf, BPF_MAP_CREATE, &ca, sizeof(ca));
...
> ------------[ cut here ]------------
> WARNING: CPU: 2 PID: 11122 at mm/page_alloc.c:2989
> __alloc_pages_nodemask+0x695/0x14e0()

thanks for the report. That's an integer overflow :(
working on the fix.
