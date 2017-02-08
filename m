From: Florian Westphal <fw@strlen.de>
Subject: Re: net/ipv4: warning in nf_nat_ipv4_fn
Date: Wed, 8 Feb 2017 23:10:06 +0100
Message-ID: <20170208221006.GA11820@breakpoint.cc>
References: <CAAeHK+zHXNetfauvokxZCrVxNc23oFEPtF2CTzvOkO-2DxQ93A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+zHXNetfauvokxZCrVxNc23oFEPtF2CTzvOkO-2DxQ93A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
> 
> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
> 
> A reproducer and .config are attached.
> 
> WARNING: CPU: 2 PID: 26582 at
> net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:261
> nf_nat_ipv4_fn+0x7f2/0xa50
> net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:261
> Kernel panic - not syncing: panic_on_warn set ...

Thats this assert:
/* We never see fragments: conntrack defrags on pre-routing
 * and local-out, and nf_nat_out protects post-routing.
 */
NF_CT_ASSERT(!ip_is_fragment(ip_hdr(skb)));


... and its wrong. I will send a patch to remove it.
