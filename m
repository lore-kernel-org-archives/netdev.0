From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC V2 PATCH 17/25] net/netpolicy: introduce
 netpolicy_pick_queue
Date: Thu, 4 Aug 2016 15:54:23 -0700
Message-ID: <20160804225423.GW5871@two.firstfloor.org>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-18-git-send-email-kan.liang@intel.com>
 <57A3A3AC.4010307@gmail.com>
 <57A3C404.8010608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, kan.liang@intel.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mingo@redhat.com, peterz@infradead.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57A3C404.8010608@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +1, I tried to bring this up here [1] in the last spin. I think only very
> few changes would be needed, f.e. on eBPF side to add a queue setting
> helper function which is probably straight forward ~10loc patch; and with
> regards to actually picking it up after clsact egress, we'd need to adapt
> __netdev_pick_tx() slightly when CONFIG_XPS so it doesn't override it.

You're proposing to rewrite the whole net policy manager as EBPF and run
it in a crappy JITer? Is that a serious proposal? It just sounds crazy
to me.

Especially since we already have a perfectly good compiler and
programming language to write system code in.

EBPF is ok for temporal instrumentation (if you somehow can accept
its security challenges), but using it to replace core 
kernel functionality (which network policy IMHO is) with some bizarre
JITed setup and multiple languages doesn't really make any sense.

Especially it doesn't make sense for anything with shared state,
which is the core part of network policy: it negotiates with multiple
users.

After all we're writing Linux here and not some research toy.

Thanks,

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
