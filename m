From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: ipv6: Orphan skbs in nf_ct_frag6_gather()
Date: Mon, 18 Apr 2016 20:35:46 +0200
Message-ID: <20160418183546.GA4289@salvia>
References: <1460570974-44050-1-git-send-email-joe@ovn.org>
 <063D6719AE5E284EB5DD2968C1650D6D5F4A226C@AcuExch.aculab.com>
 <20160414084015.GA3192@breakpoint.cc>
 <20160414103533.GA3211@salvia>
 <CAPWQB7EV-boR1_yaBeY8tQtHgc09+14jQ_q7yk=bpwrtqL+20Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Laight <David.Laight@aculab.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"diproiettod@vmware.com" <diproiettod@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPWQB7EV-boR1_yaBeY8tQtHgc09+14jQ_q7yk=bpwrtqL+20Q@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 05:35:39PM -0700, Joe Stringer wrote:
> On 14 April 2016 at 03:35, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Thu, Apr 14, 2016 at 10:40:15AM +0200, Florian Westphal wrote:
> >> David Laight <David.Laight@ACULAB.COM> wrote:
> >> > From: Joe Stringer
> >> > > Sent: 13 April 2016 19:10
> >> > > This is the IPv6 equivalent of commit 8282f27449bf ("inet: frag: Always
> >> > > orphan skbs inside ip_defrag()").
> >> > >
> >> > > Prior to commit 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free
> >> > > clone operations"), ipv6 fragments sent to nf_ct_frag6_gather() would be
> >> > > cloned (implicitly orphaning) prior to queueing for reassembly. As such,
> >> > > when the IPv6 message is eventually reassembled, the skb->sk for all
> >> > > fragments would be NULL. After that commit was introduced, rather than
> >> > > cloning, the original skbs were queued directly without orphaning. The
> >> > > end result is that all frags except for the first and last may have a
> >> > > socket attached.
> >> >
> >> > I'd have thought that the queued fragments would still want to be
> >> > resource-counted against the socket (I think that is what skb->sk is for).
> >>
> >> No, ipv4/ipv6 reasm has its own accouting.
> >>
> >> > Although I can't imagine why IPv6 reassembly is happening on skb
> >> > associated with a socket.
> >>
> >> Right, thats a much more interesting question -- both ipv4 and
> >> ipv6 orphan skbs before NF_HOOK prerouting trip.
> >>
> >> (That being said, I don't mind the patch, I'm just be curious how this
> >>  can happen).
> >
> > If this change is specific to get this working in ovs and its
> > conntrack support, then I don't think this belong to core
> > infrastructure. This should be fixed in ovs instead.
> 
> I admit I've only been able to reproduce it with OVS. My main reason
> for proposing the fix this way was just because this is what the IPv4
> code does, so I figured IPv6 should be consistent with that.

You mean that this is what you did in 029f7f3b8701 to fix this, right?

But we shouldn't add code to the core that is OVS specific for no
reason. We don't need this orphan from ipv4 and ipv6 as Florian
indicated.

Is there any chance you can fix this from OVS and its conntrack glue
code? Thanks.
