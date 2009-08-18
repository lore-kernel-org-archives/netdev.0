From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 16:45:26 +0300
Message-ID: <4A8AB076.6080906@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59891 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568AbZHRNpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 09:45:43 -0400
In-Reply-To: <4A8AA9BD.2070909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2009 04:16 PM, Gregory Haskins wrote:
> The issue here is that vbus is designed to be a generic solution to
> in-kernel virtual-IO.  It will support (via abstraction of key
> subsystems) a variety of environments that may or may not be similar in
> facilities to KVM, and therefore it represents the
> least-common-denominator as far as what external dependencies it requires.
>    

Maybe it will be easier to evaluate it in the context of these other 
environments.  It's difficult to assess this without an example.

> The bottom line is this: despite the tendency for people to jump at
> "don't put much in the kernel!", the fact is that a "bus" designed for
> software to software (such as vbus) is almost laughably trivial.  Its
> essentially a list of objects that have an int (dev-id) and char*
> (dev-type) attribute.  All the extra goo that you see me setting up in
> something like the kvm-connector needs to be done for fast-path
> _anyway_, so transporting the verbs to query this simple list is not
> really a big deal.
>    

It's not laughably trivial when you try to support the full feature set 
of kvm (for example, live migration will require dirty memory tracking, 
and exporting all state stored in the kernel to userspace).

> Note that I didn't really want to go that route.  As you know, I tried
> pushing this straight through kvm first since earlier this year, but I
> was met with reluctance to even bother truly understanding what I was
> proposing, comments like "tell me your ideas so I can steal them", and
>    

Oh come on, I wrote "steal" as a convenient shorthand for 
"cross-pollinate your ideas into our code according to the letter and 
spirit of the GNU General Public License".  Since we're all trying to 
improve Linux we may as well cooperate.

> "sorry, we are going to reinvent our own instead".

No.  Adopting venet/vbus would mean reinventing something that already 
existed.  Continuing to support virtio/pci is not reinventing anything.

> This isn't exactly
> going to motivate someone to continue pushing these ideas within that
> community.  I was made to feel (purposely?) unwelcome at times.  So I
> can either roll over and die, or start my own project.
>    

You haven't convinced me that your ideas are worth the effort of 
abandoning virtio/pci or maintaining both venet/vbus and virtio/pci.  
I'm sorry if that made you feel unwelcome.  There's no reason to 
interpret disagreement as malice though.

-- 
error compiling committee.c: too many arguments to function

