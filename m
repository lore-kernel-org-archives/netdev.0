From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v4 net-next 5/5] net: filter: split 'struct sk_filter'
 into socket and bpf parts
Date: Fri, 1 Aug 2014 12:12:36 -0700
Message-ID: <CAMEtUuxDSGysNKr12qYQAXjmb4qP45trh3qVx41W7WVduPS5zw@mail.gmail.com>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
	<1406777656-27755-6-git-send-email-ast@plumgrid.com>
	<20140731194059.GA8681@salvia>
	<CAMEtUuy+iABzHagoono+CPB=Ex4Ew4vQBK65x1jDRC9_W9L7Dw@mail.gmail.com>
	<20140801160612.GA4679@salvia>
	<CAMEtUuympZm+qVOc+4MJoSnAwSZ-Gx=tSOaHwudtP7Q92eHAtw@mail.gmail.com>
	<20140801190341.GA28642@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140801190341.GA28642@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 1, 2014 at 12:03 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > I think you can allocate the sk_filter once you get the final bpf
>> > program, then you can memcpy() it. This adds some extra overhead in
>> > the sk_attach_filter(), but that path is executed from user context
>> > and it's also a rare operation (only once to attach the filter). It's
>> > still not going to be a beauty, but IMO it's worth to focus on getting
>> > that little speed up in the packet path at the cost of adding some
>> > overhead on the socket attach path.
>>
>> memcpy of 'bpf_prog' is not just 'not a beauty', it won't work, since
>> bpf_prog is freed via work_queue due to JIT. See bpf_jit_free()
> [...]
>
> I see, in this patch you renamed sk_filter to bpf_prog in
> bpf_jit_free() so no access to sk_filter anymore and alignment needs a
> closer look.
>
> OK... let's stick to the struct bpf_prog pointer.

great. Once nft comes along we can always revisit this bit.

Dave, this patch has trivial conflict with Daniel's
("team: fix releasing uninitialized pointer to BPF prog") fix.
Let me know if you want me to respin the series or you'll patch up
the conflict yourself.

Thanks
