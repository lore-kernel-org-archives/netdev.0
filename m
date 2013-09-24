From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 11:48:53 -0700
Message-ID: <20130924114853.00003935@unknown>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	<20130924.113953.1275344954032811572.davem@redhat.com>
	<CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	<20130924.140312.1944338200709799169.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <therbert@google.com>, <David.Laight@aculab.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47792 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161Ab3IXSsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 14:48:54 -0400
In-Reply-To: <20130924.140312.1944338200709799169.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Sep 2013 14:03:12 -0400 David Miller <davem@redhat.com> wrote:
...
> >> For security reasons we absolutely cannot use it for that purpose,
> >> please stop claiming this.
> >>
> >> Any hash function which an attacker can reproduce is attackable.
> > 
...
> > that should be addressed.  It is possible to DoS attack through the
> > steering mechanism.
> 
> All of them are using a fixed, defined, key.

We selected the fixed key on purpose.  The existing mechanisms built
into the stack for preventing the impact of DOS attacks like NAPI
polling will prevent any actual damage even if someone sends lots of
packets on a single flow.  If someone overflows a receive queue that
CPU runs until it can't keep up and then hardware drops further
packets.  In this case even with a randomized seed key any single flow
can still be targeted at a queue, which is no different than a single
queue adapter.

I'm not convinced there is an actual impact in practice.
