From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 13:13:46 -0700
Message-ID: <m13aum5g1x.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
	<20071201113815.5df0960a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <lkml@rtr.ca>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54669 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbXLAUQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 15:16:19 -0500
In-Reply-To: <20071201113815.5df0960a@freepuppy.rosehill> (Stephen Hemminger's
	message of "Sat, 1 Dec 2007 11:38:15 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Actually, the whole mess would go away if the api for dev_get_by_XXXX hadn't
> been changed in the namespace transition. IMHO the interface to
> dev_get_by_name()
> should not have added a namespace parameter, of the callers in the tree, only
> two use a different namespace. So it would have been better to to introduce
> dev_get_by_name_ns() with the extra parameter.

As a general rule if you are calling dev_get_by_name and taking an &init_net
parameter that means you code has not yet been converted to actually support
network namespaces.

Not everything can be safely changed at once so we take it by steps.  When
the code fully supports network namespaces practically nothing will take
an &init_net parameter.  The network namespace parameter will come in
some form from userspace.  Either from current or from the network
socket.

Except for boot time initialization I don't know of any cases using
dev_get_by_XXXX that won't need to be modified before the network
namespace work is complete.

I believe I mentioned that this getting the fully network namespace
support was going to take a while and a bunch of patches at the
outset.

> Can we get this resolved before 2.6.24 is released? Going back and forth
> on API's is just needless frottage.

Sure.  We keep the updated dev_get_by_XXXX that takes a network
namespace parameter.

Or is their some legitimate usage of it by out of tree code that
I'm not aware of?

Eric
