From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf] netfilter: ipv6: Orphan skbs in nf_ct_frag6_gather()
Date: Thu, 14 Apr 2016 10:40:15 +0200
Message-ID: <20160414084015.GA3192@breakpoint.cc>
References: <1460570974-44050-1-git-send-email-joe@ovn.org>
 <063D6719AE5E284EB5DD2968C1650D6D5F4A226C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Joe Stringer' <joe@ovn.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"diproiettod@vmware.com" <diproiettod@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4A226C@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Joe Stringer
> > Sent: 13 April 2016 19:10
> > This is the IPv6 equivalent of commit 8282f27449bf ("inet: frag: Always
> > orphan skbs inside ip_defrag()").
> > 
> > Prior to commit 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free
> > clone operations"), ipv6 fragments sent to nf_ct_frag6_gather() would be
> > cloned (implicitly orphaning) prior to queueing for reassembly. As such,
> > when the IPv6 message is eventually reassembled, the skb->sk for all
> > fragments would be NULL. After that commit was introduced, rather than
> > cloning, the original skbs were queued directly without orphaning. The
> > end result is that all frags except for the first and last may have a
> > socket attached.
> 
> I'd have thought that the queued fragments would still want to be
> resource-counted against the socket (I think that is what skb->sk is for).

No, ipv4/ipv6 reasm has its own accouting.

> Although I can't imagine why IPv6 reassembly is happening on skb
> associated with a socket.

Right, thats a much more interesting question -- both ipv4 and
ipv6 orphan skbs before NF_HOOK prerouting trip.

(That being said, I don't mind the patch, I'm just be curious how this
 can happen).
