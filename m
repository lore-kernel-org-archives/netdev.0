From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's
  settings toslaves
Date: Mon, 11 Aug 2003 12:43:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F37C7C3.7070807@pobox.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com> <200308111720.38472.shmulik.hen@intel.com> <1060612481.1034.15.camel@jzny.localdomain> <200308111925.38278.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com, hadi@cyberus.ca
In-Reply-To: <200308111925.38278.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The answer is, like life, it's a balance.

As a general rule, we do prefer to move all code possible out of the 
Linux kernel.  We have even created "initramfs", which for 2.7, will be 
used as a vehicle to move code from the kernel to userspace, that 
previously had to be in the kernel only because it was a task that "had 
to be performed at boot time".

However, one must consider
(1) does moving code to userspace create any security holes?
(2) does moving code to userspace dramatically increase the number of 
context switches?
(3) does moving code to userspace violate some atomicity that being 
inside the kernel guarantees?

In practice, #3 is the showstopper that occurs most often.

This is why I push for a "bonding-utils" package from Jay.... because of 
the general rule above:  put it into userspace, where possible.

	Jeff
