From: ijjarvin@cs.helsinki.fi
Subject: Re: tcp crash in net-2.6 tree
Date: Sat, 31 Mar 2007 13:19:06 +0300 (EEST)
Message-ID: <mFVio6um.1175336346.4693300.ijjarvin@cs.helsinki.fi>
References: <20070330.151501.98861701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: davem@davemloft.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41053 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbXCaKTI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 06:19:08 -0400
In-Reply-To: <20070330.151501.98861701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 3/31/2007, "David Miller" <davem@davemloft.net> wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Sat, 31 Mar 2007 00:10:54 +0200
> 
> > * David Miller <davem@davemloft.net> 2007-03-30 14:43
> > > Let's not speculate, let's find out for sure if snd_una is
> > > surpassing high_seq while we're in this state.
> > >
> > > Andrew please give this debugging patch a spin, and also what
> > > is your workload?  I'd like to play with it too.
> > >
> > > I've tried to code this patch so that if the bug triggers your
> > > machine shouldn't crash and burn completely, just spit out the
> > > log message.
> >
> > I'm running into the same bug as Andew, i was able to reproduce
> > using Dave's patch within minutes:
> >
> > TCP BUG: high_seq==NULL [c3c9cc54] q[c3c94edc] t[c3c9cc54]
> >
> > The after(snd_una, high_seq) check is not triggered.
> 
> So tp->high_seq points to the tail packet end sequence.
> 
> Ilpo does this clear things up?

Thanks for the info.

I think that the if condition before the write_queue_find should check if
skb is valid before doing after(TCP_SKB_CB(skb)->seq, tp->high_seq), it
is pointing to sk_write_queue rather than a valid skb when the previous
loop exits (there might be a similar problem later in the code too). I
apologize I cannot provide a good patch at this point of time because I
moved on Thursday and the ISP hasn't yet activated the access link
(writing this from a library machine).

--
 i.
