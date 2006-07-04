From: Andy Gay <andy@andynet.net>
Subject: Re: RDMA will be reverted
Date: Tue, 04 Jul 2006 14:34:39 -0400
Message-ID: <1152038079.3285.586.camel@tahini.andynet.net>
References: <adawtazgawi.fsf@cisco.com>
	<20060630.141658.34759102.davem@davemloft.net>
	<1151708503.11835.8.camel@trinity.ogc.int>  <200607011626.04539.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:39927 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S932327AbWGDSeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 14:34:46 -0400
Received: from andyhp.tranquilitynj.net ([141.150.87.220])
 by vms044.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J1W009HU69W3NIB@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 04 Jul 2006 13:34:46 -0500 (CDT)
In-reply-to: <200607011626.04539.ak@suse.de>
To: Andi Kleen <ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-07-01 at 16:26 +0200, Andi Kleen wrote:
> On Saturday 01 July 2006 01:01, Tom Tucker wrote:
> > On Fri, 2006-06-30 at 14:16 -0700, David Miller wrote:
> > 
> > > The TOE folks have tried to submit their hooks and drivers
> > > on several occaisions, and we've rejected it every time.
> > 
> > iWARP != TOE
> 
> Perhaps a good start of that discussion David asked for would 
> be if you could give us an overview of the differences
> and how you avoid the TOE problems.

Interesting thread, I hope someone replies to Andi's request.
I've actually no real idea what RDMA, IWARP & TOE are, so I may be
barking up completely the wrong tree here. If so, apologies.

But it sounds like we're talking about technologies that offload some
part of the network/transport layer processing to the interface device?

And the primary objection to that is that it may bypass some of the cool
features of the Linux stack? Stuff like iptables and ... what exactly?

Presumably the reason why such offloading would be a Good Thing are to
do with very high speed network processing, 10G ethernet and the like.
Which sounds to me very like the way dedicated networking kit would do
that. So if you have a device that needs to be a very high performance
router, you dedicate it to that function and don't try to do clever
per-packet or -flow processing at the same time.

In the Cisco world, there's a network design approach where you consider
your equipment in three 'layers', I think they call them the core,
distribution and access layers, or something like that. The idea is that
the core layer handles the real high speed stuff, you don't do anything
much except routing/switching in there. The other layers aggregate flows
for the core, if you need extra processing (firewalls etc) you do it
somewhere in there. So, for example, the packet capture functions (sort
of like tcpdump) don't work if fast switching is in use, which it would
be in the core. Users accept these tradeoffs, because if you design it
right you can do the extra processing on some other device in the outer
layers.

So perhaps there's a good argument to make that a Linux system with the
right hardware could be considered a core device. Likely any place you
have such a system it would be dedicated to just moving data as well as
possible, and let other systems do the other stuff. You wouldn't want
your server farm systems to also be your firewalls.

Bottom line - these technologies seem to me to have a place in a well
designed network.

Just my 2c...

- Andy

> 
> -Andi
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

