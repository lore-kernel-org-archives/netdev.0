From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 19:37:57 +0200
Message-ID: <C4109B25-5680-447E-9100-DC5EE033AC14@ntop.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <20091018123811.GD27747@prithivi.gnumonks.org>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:41032 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754724AbZJRRiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 13:38:01 -0400
In-Reply-To: <20091018123811.GD27747@prithivi.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harald
many thanks for your support. As I have stated before my wish is to  
include into the the mainstream kernel some features that I have  
implemented in PF_RING and on which many users rely since very long  
time. I understand that there are some overlaps with PF_PACKET and I'm  
willing to work with the kernel maintainers to address this issue.

The only thing I want to say is that PF_RING is *not* just for  
accelerating packet capture. This was the minimal goal when in 2003 I  
have coded the first release. PF_RING is a kernel module that  
implements several features (e.g. advanced packet filtering,  
extensible architecture by means of plugins, balancing, multicore/ 
multiqueue, packet modification and retransmission) that ease the  
implementation of efficient applications not limited to packet capture  
application. So in this view PF_RING has been designed to be a  
superset of PF_PACKET, because the needs I (and many other people  
have) are not of just having efficient packet capture.

This said I'm already at work to modify PF_RING so that it's a pure  
module that does not require any change in the mainstream kernel (i.e.  
net/core/dev.c). I'm almost done so I plan to release by tomorrow a  
new PF_RING release that implements this. Of course some changes into  
the kernel (such as Ben's patch) would ease PF_RING's life and pave  
the way to new kernel modules.

Done that I will start working at the RFC that you proposed.

Cheers Luca

PS. Just to clarify, when I say 'packet filtering' I mean the ability  
for packet capture applications to specify filters more advanced that  
BPF (even if BPF is supported by PF_RING) that prevent those  
applications from receiving packets they don't like, but that in any  
case will continue their journey into the kernel; this has nothing to  
do with netfilter filtering).

On Oct 18, 2009, at 2:38 PM, Harald Welte wrote:

> Hi Brad and Luca,
>
> On Wed, Oct 14, 2009 at 08:33:08AM -0600, Brad Doctor wrote:
>
>> On behalf of the users and developers of the PF_RING project, we  
>> would
>> like to ask consideration to include the PF_RING module in the main
>> line kernel.
>
> First of all, let me state that I think the mainline support for  
> nProbe/nTop is
> something that I have been hoping for many years.  I think the  
> performance you
> are achieving is remarkable, and it would be very usable to have this
> capability of high performance zero-copy packet access from  
> userspace as a
> stock feature of the Linux kernel.
>
> The actual PF_RING implementation has been criticized a couple of  
> times even in
> the past.  One general point I remember from past discussions in the  
> kernel
> network community was that there is too much overlap with PF_PACKET,  
> and that
> this could possibly be extended with a ring buffer rather than  
> replaced with a
> fairly similar alternative mechanism.
>
> So let's see what kind of solution the current discussion thread  
> will come up
> with... let's hope eventually we'll have the functionality in the  
> kernel.
> -- 
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> = 
> = 
> = 
> = 
> = 
> = 
> ======================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                  (ETSI EN 300 175-7  
> Ch. A6)

