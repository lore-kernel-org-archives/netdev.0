From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Thu, 8 Aug 2013 10:04:48 +0200
Message-ID: <20130808100448.010cd96d@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-4-git-send-email-kaber@trash.net>
	<20130807222600.51eeca09@redhat.com>
	<20130807205602.GA21463@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130807205602.GA21463@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 7 Aug 2013 22:56:03 +0200 Patrick McHardy <kaber@trash.net> wrote:
> On Wed, Aug 07, 2013 at 10:26:00PM +0200, Jesper Dangaard Brouer wrote:
> > On Wed,  7 Aug 2013 19:42:49 +0200 Patrick McHardy <kaber@trash.net> wrote:

[...]
> > Besides shouldn't nth->ack_seq be zero, in a SYN packet? This is the
> > SYN "replayed" towards the server right?
> > 
> > I also pointed to this in an earlier patch Martin showed me, but he
> > reported that changing this resulted in bad behavior.  So, I would
> > request Martin to re-test this part.
> 
> Right, it should be zero, but it doesn't matter since the ACK flag isn't
> set. This is used to propagate the sequence number to the hook function
> to initialize the sequence adjustment data. While in the target function,
> we don't have any connection tracking state to store this in. We could
> set it to zero after that, but it shouldn't matter.

I think it deserves a comment in the code, that you are using ack_seq,
to relay this information to the hook, as its not obvious.

And I think we should set it to zero after that, else it will be
visible on the wire, and wireshark complains (with a warning) when it
sees pure SYN packets with a non-zero ACK number (Martin send me a dump
some time ago, and I just checked).

p.s. thanks for working on this module, which we discussed during the
Netfilter Workshop 2013.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
