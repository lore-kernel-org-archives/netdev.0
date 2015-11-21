From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Sat, 21 Nov 2015 15:18:30 -0800
Message-ID: <20151121231829.GA51711@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
 <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
 <20151120033040.GA13060@ast-mbp.thefacebook.com>
 <1448015413.2300190.445198593.6A586A15@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34992 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759579AbbKUXSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 18:18:37 -0500
Received: by pacej9 with SMTP id ej9so152647379pac.2
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 15:18:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448015413.2300190.445198593.6A586A15@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 11:30:13AM +0100, Hannes Frederic Sowa wrote:
> Hi Alexei,
> 
> > If user space can be see both 'count' and 'max_entries', it can be very
> > tempting to start assuming 'full' and 'empty' state of the map which will
> > lead to race conditions and bad design.
> > bpf programs and maps are inherently multi-thread and concurrent.
> > If userapp wants to do the counting of elements it needs to do so on its
> > own
> > and shoot itself in the foot eventually.
> > For the same reason I don't want to see BPF_MAP_GET_COUNT command.
> 
> Hmmm... I don't understand your argument. This is the same with memory
> management in general and we still report memory statistics to user
> space. I really would find it helpful to have a feeling if a map is
> nearly full or nearly empty.

memory is not the same, since it's a shared resource and knowledge
about consumption by the process gives no insight whether next malloc()
will succeed or not.

> We can also count collisions or the load in the buckets, but some
> evidence what is going on would be nice, wouldn't it?

reporting collisions may be ok, since it's probably hard to exploit
such stats, but security may become a concern in some use cases,
so may not be such a good idea at the end.

In general when user space passed kernel some numbers (like type,
element size, max_entries) it's ok to report it back via fdinfo.
Anything else I'd rather keep private.
debugging in general should be done by debugging tools.
Like I often use kprobe+bpf to debug networking+bpf :)
Unfortunately kprobe+bpf doesn't work to debug itself, but then
regular tracing and kprobe comes to rescue.
