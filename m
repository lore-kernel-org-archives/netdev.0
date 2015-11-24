From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Wed, 25 Nov 2015 00:13:37 +0100
Message-ID: <1448406817.1506117.449252449.007F22F3@webmail.messagingengine.com>
References: <20151124205537.GC23215@breakpoint.cc>
 <CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
 <20151124222242.GD23215@breakpoint.cc>
 <20151124.172547.672210919260359472.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com,
	davejwatson@fb.com, alexei.starovoitov@gmail.com
To: David Miller <davem@redhat.com>, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40649 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbbKXXNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 18:13:38 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id E36B72032D
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 18:13:37 -0500 (EST)
In-Reply-To: <20151124.172547.672210919260359472.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Nov 24, 2015, at 23:25, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 24 Nov 2015 23:22:42 +0100
> 
> > Yes, I get that point, but I maintain that KCM is a strange workaround
> > for bad userspace design.
> 
> I fundamentally disagree with you.
> 
> And even if I didn't, I would be remiss to completely dismiss the
> difficulty in changing existing protocols and existing large scale
> implementations of them.  If we can facilitate them somehow then
> I see nothing wrong with that.
> 
> Neither you nor Hannes have made a strong enough argument for me
> to consider Tom's work not suitable for upstream.
> 
> Have you even looked at the example userspace use case he referenced
> and considered the constraints under which it operates?  I seriously
> doubt you did.

If you are referring to thrift and tls framing, yes indeed, I did. I
have experience in google protocol buffers and once cared about an
in-house RPC implementation. All I learned is that this approach is
prone to starving or building up huge messages in kernel space. That is
why xml streaming in form of StAX from the Java world is used more and
more and even Apache Jackson does provide a streaming API for JSON which
I once used because JSON messages streamed as hash tables got too big
and were prone to starve. Even user space needs to be careful what sizes
of messages they accept otherwise DoS attacks are possible and jvms with
small heaps are getting OutOfMemoryExceptions. This is the same in other
high level languages, non-GCed (or without copying garbage collector)
languages just reallocate and cause fragmentation in the long term. Even
keeping multiple 16MB chunks for HTTP/2 in the kernel heap so that user
space can read them in on go seems very much bad in my opinion.

Neither of all those approaches delimit datagrams by "read() barriers".
I think the alternatives should be tried. I think this framework is only
applicable to a small fractions of RPC systems.

Thanks for following up, :)
Hannes
