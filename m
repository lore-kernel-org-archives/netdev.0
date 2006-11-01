From: David Miller <davem@davemloft.net>
Subject: Re: TCP congestion graphs (2.6.19-rc4)
Date: Tue, 31 Oct 2006 17:30:28 -0800 (PST)
Message-ID: <20061031.173028.118970335.davem@davemloft.net>
References: <20061031120016.75dc4c3c@freekitty>
	<7335583a0610311525h10cf4e75x42e421d3eb6f53aa@mail.gmail.com>
	<20061031161007.0fdf5c63@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidwei79@gmail.com, rhee@eos.ncsu.edu, sha2@ncsu.edu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64422
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946262AbWKABa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 20:30:28 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031161007.0fdf5c63@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 31 Oct 2006 16:10:07 -0800

> On Tue, 31 Oct 2006 15:25:16 -0800
> "Xiaoliang (David) Wei" <davidwei79@gmail.com> wrote:
> 
> > It seems that the default Vegas alpha parameter in the rc4 is 1...
> > 
> > I observed similar situation with the NS2Linux simulator (with 2.6.16
> > code) and found that if alpha=1, delayed ack will make it broken
> > (keeping cwnd very low without real congestion)
> > 
> > See details at http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/index.html#vegas
> > 
> > (Basically alpha==1 means Vegas seeks to see a delay of about 1 packet
> > worth. With delayed ack, 1 packet worth of delay is common even with
> > no congestion.)
> > 
> > To make Vegas work, I'd suggest to raise alpha to at least 2 or 3.
> > (and beta has to be at least as large as alpha.)
> > 
> > -David
> > 
> 
> I ran with the current default:
> 	alpha = 1 (scaled 2)
> 	beta  = 3 (scaled 6)
> 	gamma = 1 (scaled 2)

Testing with alpha=2 and beta=4 would be interesting.

Brakmo and Peterson don't see this delayed ACK behavior in their tests
in the original Vegas paper.  I read through it a few times and I see
no explicit mention of whether they had delayed ACKs enabled or not in
any of there tests.

I seem to recall that it was very popular around that time to analyze
TCP changes with delayed ACKs disabled since it made the results
easier to analyze (which in my opinion invalidates any such results,
since in the real world you never run with delayed ACKs off).  So
perhaps the Vegas folks were doing something similar and just didn't
think it was worth mentioning :-)

BTW, Stephen, can you give a short HOWTO on how you generate those
graphs, given a tcpdump trace?  Thanks a lot.
