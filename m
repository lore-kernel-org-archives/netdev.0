From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings toslaves
Date: Mon, 11 Aug 2003 14:41:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308112141.h7BLftpS015012@death.ibm.com>
References: <jgarzik@pobox.com>
Cc: shmulik.hen@intel.com, hadi@cyberus.ca,
   Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: Message from Jeff Garzik <jgarzik@pobox.com>
   of "Mon, 11 Aug 2003 12:43:47 EDT." <3F37C7C3.7070807@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>The answer is, like life, it's a balance.
[...]
>This is why I push for a "bonding-utils" package from Jay.... because of 
>the general rule above:  put it into userspace, where possible.

	Hmm.  My impression from our prior discussions was that your
interest in moving ifenslave out of the kernel source and into its own
package was more of a source code management concern rather than
moving functionality from the kernel into user space (because
ifenslave is in user space to begin with).

	Anyway, for most of the core bonding failover logic, I don't
see how a user space daemon implementation can perform equivalently to
a kernel-only implementation.  I could be wrong (I haven't done any
testing) but for the core "eth0 is dead, enable eth1" type stuff, it
seems to me that in-kernel beats "user space yakking with kernel" for
reliability and speed, particularly on heavily loaded systems.

	Now, that said, I can see a use for a user space monitoring /
control program, for the "strategic" problems (as opposed to the
"tactical" problems, like the previous paragraph).  If we want to,
e.g., monitor bandwidth usage and add or remove links from the
aggregation, that is (a) not as time critical, and (b) somewhat
fuzzier in definition.  Such a user space program could also interface
with various system management or HA thingies and report status for
its activities as well as the activities that bonding performs
independent of it.

	One thought I've had (which dovetails somewhat with an earlier
comment from Laurent) is a tcpdump/bpf-style "policy engine" blob in
the kernel, which is programmed from user space with enough brains to
handle the "tactical" level problems (the "strategic" problems might
be more than such a blob could handle, and if its easy enough to yak
with user space for those problems, it may not be necessary).  I
haven't done much more than think about this, though; it may very well
be overkill for the basic stuff.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
