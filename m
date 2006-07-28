From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 19:33:58 -0700 (PDT)
Message-ID: <20060727.193358.18307185.davem@davemloft.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	<20060727.183415.104032934.davem@davemloft.net>
	<20060728022229.GA2106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9662
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751807AbWG1CeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 22:34:14 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060728022229.GA2106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Jul 2006 12:22:29 +1000

> I suppose another case in point is IPv4 autoconf which
> is *still* in the kernel after all these years.

At least in that case, H. Peter Anvin has put together a
klibc equivalent.

Klibc is one possible way out of this quagmire.  But we have to wait
until everyone is able to convert over to it.  This isn't like
changing the module interfaces and APIs, for example, it is a much
larger change from the userland perspective.  And it took a long time
for the module bits to propagate fully, which as I said was a less
drastic case.

And klibc is only really good for bootup stuff and loading initial
drivers.  It probably cannot be applied to things like ARP and
NDISC.  IPv4 autoconf works as a good application of klibc because
you only need it to run from the initial ramdisk on bootup.

> However, to draw an analogy we're kind of stuck in a bog here.  So
> while we can't extricate ourselves easily, we should attempt to come
> up with ways of eventually lifting us out.  We should also try to
> avoid any actions that'll cause us to sink deeper :)

That's why we are very careful when evaluating new protocol
implementations that want to be in the kernel.  The first question we
always ask is "can you do this reasonably in userspace?"

