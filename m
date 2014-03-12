From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v9 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Wed, 12 Mar 2014 13:34:54 -0700
Message-ID: <CAMEtUuwUFhJdvtdrO8xcqytPRm=iqfkVu1Q6RzyzeuEeSpay0w@mail.gmail.com>
References: <1394512892-5448-1-git-send-email-ast@plumgrid.com>
	<1394512892-5448-2-git-send-email-ast@plumgrid.com>
	<20140312.152215.347361365901821816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140312.152215.347361365901821816.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 12:22 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Mon, 10 Mar 2014 21:41:30 -0700
>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 1a869488b8ae..2c13d000389c 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -3054,6 +3054,7 @@ extern int              netdev_max_backlog;
>>  extern int           netdev_tstamp_prequeue;
>>  extern int           weight_p;
>>  extern int           bpf_jit_enable;
>> +extern int           bpf_ext_enable;
>
> I don't like seeing config ifdefs in C code, so please adjust the
> bpf_jit_enable declaration with something like:
>
> #ifdef CONFIG_BPF_JIT
> extern int              bpf_jit_enable;
> #else
> #define bpf_jit_enable  0
> #endif

agree. that's definitely cleaner.

>> +#ifdef CONFIG_64BIT
>> +             DL(BPF_STX, BPF_XADD, BPF_DW)
>> +#endif
>  ...
>> +#ifdef CONFIG_64BIT
>> +BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
>> +     atomic64_add((u64)X, (atomic64_t *)(ulong)(A + insn->off));
>> +     CONT;
>> +#endif
>
> I'm not too happy about instructions which are only available on
> certain architectures.
>
> I'd rather see best effort emulation than wholesale lack of support.
>
> We have an implementation of 64-bit atomics for 32-bit systems or
> those without true atomic compare-and-saw etc. ops in lib/atomic64.c
> so the routines are always available.

Good point. Will do.

Thanks
