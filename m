From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 08/16] bpf: add hashtable type of BPF maps
Date: Wed, 23 Jul 2014 14:42:01 -0700
Message-ID: <CAMEtUuxx7e2PHv4cpPtnOHqamandoE3Y8-uMdRBiRGZKYGbv8w@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-9-git-send-email-ast@plumgrid.com>
	<CAGXu5jK1hrwvPs7f+mSOer+81J9SBxwMrqb=6fFeZQ7hd-FMzA@mail.gmail.com>
	<CAMEtUuyRUG6ZdRvL0JuakD0zPdYo3WoqQepK7_b_MW+r2aVzVA@mail.gmail.com>
	<CAGXu5jLbcrR76=omiqRNERhjZS8bsR1-jG+Ctra97uCrpHLPUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLbcrR76=omiqRNERhjZS8bsR1-jG+Ctra97uCrpHLPUA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 1:33 PM, Kees Cook <keescook@chromium.org> wrote:
>>
>>>> +       htab->slab_name = kasprintf(GFP_USER, "bpf_htab_%p", htab);
>>>
>>> This leaks a kernel heap memory pointer to userspace. If a unique name
>>> needed, I think map_id should be used instead.
>>
>> it leaks, how? slabinfo is only available to root.
>> The same code exists in conntrack:
>> net/netfilter/nf_conntrack_core.c:1767
>
> Right, in extreme cases, there are system configurations where leaking
> addresses even to root can be considered a bug. There are a lot of
> these situations in the kernel still, that's true. However, if we can
> at all avoid it, I'd really like to avoid adding new ones. Nearly all
> the cases of using a memory pointer is for uniqueness concerns, but I
> think can already get that from the map_id.

ok. fair enough. I think slab name doesn't have to be unique anymore.
It's used to be a requirement in older kernels. If it is ok to reuse now,
I'll just use the same for all hash-type maps.
Advice from slab expert would be great...
