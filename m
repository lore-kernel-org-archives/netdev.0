From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: fanotify as syscalls
Date: Tue, 15 Sep 2009 16:49:34 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
References: <20090911.114620.260824240.davem@davemloft.net>  <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>  <20090911204602.GA19371@shareable.org>  <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>  <20090911212731.GA19901@shareable.org>
 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>  <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>  <20090914140720.GA8564@ioremap.net>  <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>  <20090915201620.GB32192@ioremap.net>
 <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 15 Sep 2009, Eric Paris wrote:
> 
> I don't see what's gained using netlink.

I'm personally not a big believer in netlink. What's the point, really? If 
you are sending datagrams back-and-forth, go wild. But if it's more 
structured than that, netlink has no actual upsides as far as I can tell.

Same goes for sockets in this case, actually. What's the upside?

I'll throw out a couple of upsides of actual system calls, people can feel 
free to comment:

 - things like 'strace' _work_ and the traces make sense, and you 
   generally see what the app is trying to do from the traces (sure, it 
   takes some time for strace to learn new system calls, but even when it 
   only gives a system call number, it's never any worse than some 
   "made-up packet interface".

 - if you have a system call definition, it tends to be a much stricter 
   interface than "let's send some packets around with a network 
   interface".

 - No unnecessary infrastructure.

That said, maybe the netlink/socket people can argue for their 
standpoints.

(And btw, I still want to know what's so wonderful about fanotify that we 
would actually want yet-another-filesystem-notification-interface. So I'm 
not sayying that I'll take a system call interface. I just don't think 
that hiding interfaces behind some random packet interface is at all any 
better)

		Linus
