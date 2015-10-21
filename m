From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 21:11:53 +0200
Message-ID: <5243548.YbVhhU6W8t@wuerfel>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net> <4129407.LpDXnpSZOL@wuerfel> <5627C549.9080600@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:54576 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbbJUTMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 15:12:01 -0400
In-Reply-To: <5627C549.9080600@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 October 2015 10:03:05 Guenter Roeck wrote:
> >
> > Something like this?
> >
> > static inline u64 of_translate_address(struct device_node *np, const __be32 *addr)
> > {
> > #if defined(CONFIG_SPARC) || defined(CONFIG_M68K)
> >       int pna = of_n_addr_cells(np);
> >       u64 ret = be32_to_cpu(addr[pna - 1]);
> >
> >       if (pna > 1)
> >               ret += (u64)be32_to_cpu(addr[pna - 2]) << 32;
> >
> >       return ret;
> 
> That suggests that sparc would need a translation after all, which
> seems to contradict what David said earlier.

No, not a translation: the value is used without any offset that
factors in the location of the bus, the above is just the shortest
possible way to read the 64-bit number from a big-endian property
of variable length.

> Anyway, if it gets that complicated, I think we should stick with
> just returning OF_BAD_ADDR. The above really suggests the need for
> an architecture specific solution.

Probably no harm in this really: the far more common
of_address_to_resource() and of_iomap() helpers are equally
broken on SPARC and we just return a runtime error for those
as well without CONFIG_OF_ADDRESS rather than breaking the build.

	Arnd
