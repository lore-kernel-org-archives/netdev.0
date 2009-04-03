From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 15:15:53 +0300
Message-ID: <49D5FDF9.7090602@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws> <49D5FAFD.1010102@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56988 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755221AbZDCMP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 08:15:29 -0400
In-Reply-To: <49D5FAFD.1010102@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
> So again, I am proposing for consideration of accepting my work (either
> in its current form, or something we agree on after the normal review
> process) not only on the basis of the future development of the
> platform, but also to keep current components in their running to their
> full potential.  I will again point out that the code is almost
> completely off to the side, can be completely disabled with config
> options, and I will maintain it.  Therefore the only real impact is to
> people who care to even try it, and to me.
>   

Your work is a whole stack.  Let's look at the constituents.

- a new virtual bus for enumerating devices.

Sorry, I still don't see the point.  It will just make writing drivers 
more difficult.  The only advantage I've heard from you is that it gets 
rid of the gunk.  Well, we still have to support the gunk for non-pv 
devices so the gunk is basically free.  The clean version is expensive 
since we need to port it to all guests and implement exciting features 
like hotplug.

- finer-grained point-to-point communication abstractions

Where virtio has ring+signalling together, you layer the two.  For 
networking, it doesn't matter.  For other applications, it may be 
helpful, perhaps you have something in mind.

- your "bidirectional napi" model for the network device

virtio implements exactly the same thing, except for the case of tx 
mitigation, due to my (perhaps pig-headed) rejection of doing things in 
a separate thread, and due to the total lack of sane APIs for packet 
traffic.

- a kernel implementation of the host networking device

Given the continuous rejection (or rather, their continuous 
non-adoption-and-implementation) of my ideas re zerocopy networking aio, 
that seems like a pragmatic approach.  I wish it were otherwise.

- a promise of more wonderful things yet to come

Obviously I can't evaluate this.

Did I miss anything?

Right now my preferred course of action is to implement a prototype 
userspace notification for networking.  Second choice is to move the 
host virtio implementation into the kernel.  I simply don't see how the 
rest of the stack is cost effective.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

