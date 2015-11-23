From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Mon, 23 Nov 2015 10:03:34 -0800
Message-ID: <20151123180333.GB78190@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
 <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
 <20151120033040.GA13060@ast-mbp.thefacebook.com>
 <1448015413.2300190.445198593.6A586A15@webmail.messagingengine.com>
 <20151121231829.GA51711@ast-mbp.thefacebook.com>
 <1448295118.4062584.447768561.3963C28E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34637 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbbKWSDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 13:03:37 -0500
Received: by padhx2 with SMTP id hx2so198159511pad.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 10:03:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448295118.4062584.447768561.3963C28E@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 05:11:58PM +0100, Hannes Frederic Sowa wrote:
> 
> Actually, that is the reason why I mentioned it, so *the admin* can see
> something is going on. Do you want to protect ebpf from root? Skynet? ;)

correct. To me both root and non-root are users in the first place and
they both shouldn't be allowed to misuse it.

> In my opinion the kernel never should hide any information of the admin
> if they are accessible easily. Sampling the number of failed updates to
> a map or printing it via procfs/ebpffs seems to be just a matter of how
> difficult it should be done. The map has a lock, so the number is fairly

map_lookup is actually lockless. It's a critical path and should be
as fast as possible. No extra stats just for debugging.

> accurate. Sampling and plotting size of hash maps without having kprobes
> installed would be a nice thing, because it reduces complexity and this
> is nice to have.

doing 'cat' from procfs is, of course, easier to use, but it's an extra
code that permenanetly lives in memory, whereas kprobe+bpf is a run-time
debugging.
