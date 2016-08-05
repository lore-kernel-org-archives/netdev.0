From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC V2 PATCH 17/25] net/netpolicy: introduce netpolicy_pick_queue
Date: Fri, 5 Aug 2016 07:41:40 -0700
Message-ID: <CALx6S374fUxDd1_=db8hg4YsMoMZ_UwM3_uNW4JsXbVkHUEmHQ@mail.gmail.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-18-git-send-email-kan.liang@intel.com> <57A3A3AC.4010307@gmail.com>
 <57A3C404.8010608@iogearbox.net> <20160804225423.GW5871@two.firstfloor.org> <57A3DB2F.1010909@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andi Kleen <andi@firstfloor.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"Liang, Kan" <kan.liang@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@redhat.com>, peterz@infradead.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
	Kees Cook <keescook@chromium.org>, viro@zeniv.linux.org.uk,
	gorcunov@openvz.org, John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Decotigny <decot@googlers.com>,
	Florian Westphal <fw@strlen.de>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	rdunlap@infradead.org, Cong Wang <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <han
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57A3DB2F.1010909@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 4, 2016 at 5:17 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/05/2016 12:54 AM, Andi Kleen wrote:
>>>
>>> +1, I tried to bring this up here [1] in the last spin. I think only very
>>> few changes would be needed, f.e. on eBPF side to add a queue setting
>>> helper function which is probably straight forward ~10loc patch; and with
>>> regards to actually picking it up after clsact egress, we'd need to adapt
>>> __netdev_pick_tx() slightly when CONFIG_XPS so it doesn't override it.
>>
>>
>> You're proposing to rewrite the whole net policy manager as EBPF and run
>> it in a crappy JITer? Is that a serious proposal? It just sounds crazy
>> to me.
>>
>> Especially since we already have a perfectly good compiler and
>> programming language to write system code in.
>>
>> EBPF is ok for temporal instrumentation (if you somehow can accept
>> its security challenges), but using it to replace core
>> kernel functionality (which network policy IMHO is) with some bizarre
>> JITed setup and multiple languages doesn't really make any sense.
>>
>> Especially it doesn't make sense for anything with shared state,
>> which is the core part of network policy: it negotiates with multiple
>> users.
>>
>> After all we're writing Linux here and not some research toy.
>
>
> From what I read I guess you didn't really bother to look any deeper into
> this bizarre "research toy" to double check some of your claims. One of the
> things it's often deployed for by the way is defining policy. And the
> suggestion here was merely to explore existing infrastructure around things
> like tc and whether it already resolves at least a part of your net policy
> manager's requirements (like queue selection) or whether existing
> infrastructure
> can be extended with fewer complexity this way (as was mentioned with a new
> cls module as one option).

+1. The SO_REUSEPORT + BPF patches have already demonstrated the value
of making policy in the kernel programmable. There's no reason to
believe that model can't be extended to cover packet steering in the
data path for TX or RX as well as other cases.

Tom
