From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: GPF in __netlink_ns_capable
Date: Mon, 18 Jan 2016 17:20:47 +0800
Message-ID: <20160118092047.GA30682@gondor.apana.org.au>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
 <CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 16, 2016 at 01:08:33AM +0100, Richard Weinberger wrote:
> On Fri, Jan 15, 2016 at 11:31 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Call Trace:
> >  [<     inline     >] netlink_ns_capable net/netlink/af_netlink.c:1417
> >  [<ffffffff8529c0a5>] netlink_capable+0x25/0x30 net/netlink/af_netlink.c:1432
> 
> Hmm, we're crashing because NETLINK_CB(skb).sk is NULL.
> netlink_dump() creates a new skb without a netlink control block,
> but infiniband's dump functions use netlink_capable() which needs a valid
> NETLINK_CB(skb).sk.
> 
> What about something like that?

No you can't do it here as netlink_unicast also calls this and for
that case you'd be overwriting the original sending user-space
socket with the kernel socket.

I'm adding Eric Bierderman as he wrote some of the code in question.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
