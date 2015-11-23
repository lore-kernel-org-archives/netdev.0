From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Mon, 23 Nov 2015 20:12:19 +0100
Message-ID: <1448305939.1624527.447961889.5D80B022@webmail.messagingengine.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
 <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
 <20151120033040.GA13060@ast-mbp.thefacebook.com>
 <1448015413.2300190.445198593.6A586A15@webmail.messagingengine.com>
 <20151121231829.GA51711@ast-mbp.thefacebook.com>
 <1448295118.4062584.447768561.3963C28E@webmail.messagingengine.com>
 <20151123180333.GB78190@ast-mbp.thefacebook.com>
 <5653647D.7020903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42817 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751127AbbKWTMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 14:12:20 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 2DF4620C19
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 14:12:20 -0500 (EST)
In-Reply-To: <5653647D.7020903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015, at 20:09, John Fastabend wrote:
> On 15-11-23 10:03 AM, Alexei Starovoitov wrote:
> > On Mon, Nov 23, 2015 at 05:11:58PM +0100, Hannes Frederic Sowa wrote:
> >>
> >> Actually, that is the reason why I mentioned it, so *the admin* can see
> >> something is going on. Do you want to protect ebpf from root? Skynet? ;)
> > 
> > correct. To me both root and non-root are users in the first place and
> > they both shouldn't be allowed to misuse it.
> > 
> >> In my opinion the kernel never should hide any information of the admin
> >> if they are accessible easily. Sampling the number of failed updates to
> >> a map or printing it via procfs/ebpffs seems to be just a matter of how
> >> difficult it should be done. The map has a lock, so the number is fairly
> > 
> > map_lookup is actually lockless. It's a critical path and should be
> > as fast as possible. No extra stats just for debugging.
> > 
> >> accurate. Sampling and plotting size of hash maps without having kprobes
> >> installed would be a nice thing, because it reduces complexity and this
> >> is nice to have.
> > 
> > doing 'cat' from procfs is, of course, easier to use, but it's an extra
> > code that permenanetly lives in memory, whereas kprobe+bpf is a run-time
> > debugging.
> 
> Hopefully not jumping in off-base here (I've read most the thread), but
> what I've been doing is loading programs with debug ebpf code in them
> to keep a statistics map(s) and then I read that from  userspace for
> stats. It works pretty well and lets me compile out the debug code when
> I want and also doesn't need kprobe at all. Also I can implement
> sampling so that the debug code only runs every .01% or something like
> that so it can be used in "real" systems. My "real" systems are just a
> couple node test setup but it seems to be ok ;)

Ok, I am fine to wait until there is user demand.

Anyway, all you refer to is code you have under your control. I am
worried about bpf code that is not under my control.

Thanks,
Hannes
