From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Mon, 23 Nov 2015 17:11:58 +0100
Message-ID: <1448295118.4062584.447768561.3963C28E@webmail.messagingengine.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
 <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
 <20151120033040.GA13060@ast-mbp.thefacebook.com>
 <1448015413.2300190.445198593.6A586A15@webmail.messagingengine.com>
 <20151121231829.GA51711@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34122 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568AbbKWQL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 11:11:59 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 3AB3120A55
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 11:11:59 -0500 (EST)
In-Reply-To: <20151121231829.GA51711@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 22, 2015, at 00:18, Alexei Starovoitov wrote:
> On Fri, Nov 20, 2015 at 11:30:13AM +0100, Hannes Frederic Sowa wrote:
> > Hi Alexei,
> > 
> > > If user space can be see both 'count' and 'max_entries', it can be very
> > > tempting to start assuming 'full' and 'empty' state of the map which will
> > > lead to race conditions and bad design.
> > > bpf programs and maps are inherently multi-thread and concurrent.
> > > If userapp wants to do the counting of elements it needs to do so on its
> > > own
> > > and shoot itself in the foot eventually.
> > > For the same reason I don't want to see BPF_MAP_GET_COUNT command.
> > 
> > Hmmm... I don't understand your argument. This is the same with memory
> > management in general and we still report memory statistics to user
> > space. I really would find it helpful to have a feeling if a map is
> > nearly full or nearly empty.
> 
> memory is not the same, since it's a shared resource and knowledge
> about consumption by the process gives no insight whether next malloc()
> will succeed or not.
> 
> > We can also count collisions or the load in the buckets, but some
> > evidence what is going on would be nice, wouldn't it?
> 
> reporting collisions may be ok, since it's probably hard to exploit
> such stats, but security may become a concern in some use cases,
> so may not be such a good idea at the end.

Actually, that is the reason why I mentioned it, so *the admin* can see
something is going on. Do you want to protect ebpf from root? Skynet? ;)

> In general when user space passed kernel some numbers (like type,
> element size, max_entries) it's ok to report it back via fdinfo.
> Anything else I'd rather keep private.
> debugging in general should be done by debugging tools.
> Like I often use kprobe+bpf to debug networking+bpf :)
> Unfortunately kprobe+bpf doesn't work to debug itself, but then
> regular tracing and kprobe comes to rescue.

In my opinion the kernel never should hide any information of the admin
if they are accessible easily. Sampling the number of failed updates to
a map or printing it via procfs/ebpffs seems to be just a matter of how
difficult it should be done. The map has a lock, so the number is fairly
accurate. Sampling and plotting size of hash maps without having kprobes
installed would be a nice thing, because it reduces complexity and this
is nice to have.

Bye,
Hannes
