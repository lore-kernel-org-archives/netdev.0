From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 6 Oct 2015 12:26:53 -0700
Message-ID: <5614207D.4050708@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com>
 <20151006071347.GB14093@gmail.com> <561380BB.4040506@iogearbox.net>
 <20151006082048.GA18287@gmail.com> <561388D1.30406@iogearbox.net>
 <561409EC.5050005@plumgrid.com>
 <1444154160.9555.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444154160.9555.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/6/15 10:56 AM, Eric Dumazet wrote:
> On Tue, 2015-10-06 at 10:50 -0700, Alexei Starovoitov wrote:
>
>> was also thinking that we can do it only in paths that actually
>> have multiple protocol layers, since today bpf is mainly used with
>> tcpdump(raw_socket) and new af_packet fanout both have cb cleared
>> on RX, because it just came out of alloc_skb and no layers were called,
>> and on TX we can clear 20 bytes in dev_queue_xmit_nit().
>> af_unix/netlink also have clean skb. Need to analyze tun and sctp...
>> but it feels overly fragile to save a branch in sk_filter,
>> so planning to go with
>> if(unlikely(prog->cb_access)) memset in sk_filter().
>>
>
> This will break TCP use of sk_filter().
> skb->cb[] contains useful data in TCP layer.

oops. thanks for catching. In case of sk_filter on top of tcp sock,
it shouldn't be looking at cb at all.
I'm thinking to send a patch to get rid of cb access for socket filters
all together until better solution found.
