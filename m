From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v9 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Wed, 12 Mar 2014 15:43:02 -0700
Message-ID: <CAMEtUuz-e6zQdK975mfLX-UBRt001L0KvXPDtELyTk-rzb2jQg@mail.gmail.com>
References: <1394512892-5448-1-git-send-email-ast@plumgrid.com>
	<1394512892-5448-2-git-send-email-ast@plumgrid.com>
	<CAHA+R7P=XAWAPkJTZSfHs02-+V+VOMQ04ZNNjY6LmPdRENzCJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
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
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7P=XAWAPkJTZSfHs02-+V+VOMQ04ZNNjY6LmPdRENzCJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 3:16 PM, Cong Wang <cwang@twopensource.com> wrote:
> (Sorry for jumping into this thread late.)
>
> On Mon, Mar 10, 2014 at 9:41 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>> 3. tracing filters systemtap-like with extended BPF
>>
>> 4. OVS with extended BPF
>>
>> 5. nftables with extended BPF
>
> If you plan to use extended BPF out of networking, does
> it make sense to make it independent of networking?
> That is, rename those sk_*() APIs?

well, v1 and v2 series already demonstrate how ebpf can be used for tracing.
That's why in v1 series they were under kernel/ dir, but since it's
a natural bpf extension that reuses a lot of bpf pieces, it makes sense
for the whole thing be in net/core/filter.c and in linux/filter.h
I believe that was a consensus in v2-v3 series.
I don't want to rename the whole thing once again.
Also seccomp is not networking, but it already uses bpf and
after these patches ebpf. So net/core/filter.c location is fine.

>>
>> +int bpf_ext_enable __read_mostly;
>> +
>
> This could be converted to a jump label, no?

yes, but it's not in critical path, so no need.

Thank you for taking a look!
Even late feedback is always appreciated.
