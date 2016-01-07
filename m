From: Florian Westphal <fw@strlen.de>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with
 fragmentation
Date: Thu, 7 Jan 2016 13:03:39 +0100
Message-ID: <20160107120339.GC23789@breakpoint.cc>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
 <CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
 <CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
 <20160106210532.GE27290@indiana.gru.redhat.com>
 <20160106220334.GA23789@breakpoint.cc>
 <20160106234943.GB23789@breakpoint.cc>
 <CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Jan 7, 2016 at 2:49 AM, Florian Westphal <fw@strlen.de> wrote:
> > ... but it seems that those three are the only affected callers
> > of skb_gso_segment (tbf is ok since skb isn't owned by anyone,
> > ovs does save/restore already).
> >
> > I think this patch is the right way, we just need similar
> > save/restore in nfqnl_enqueue_packet and xfrm_output_gso().
> 
> Which CB could be here? at this point skb isn't owned by netlink yet.

inet(6)_skb_parm, nfqnl_enqueue_packet is called via netfilter hooks, skb
is owned by ipv4 or ipv6 stack.

> > The latter two can be used by either ipv4 or ipv6 so it might
> > be preferable to just save/restore sizeof(struct skb_gso_cb);
> > or a union of inet_skb_parm+inet6_skb_parm.
> 
> Or just shift GSO CB and add couple checks like
> BUILD_BUG_ON(sizeof(SKB_GSO_CB(skb)->room) < sizeof(*IPCB(skb)));

Right, that works too.
