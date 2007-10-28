From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: 28 Oct 2007 21:18:40 +0100
Message-ID: <ygfk5p7vvq7.fsf@janus.isnogud.escape.de>
References: <E1IkAo9-0006xM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com (Joe Perches), davem@davemloft.net,
	acme@ghostprotocols.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:39774 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381AbXJ1UUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 16:20:44 -0400
In-Reply-To: <E1IkAo9-0006xM-00@gondolin.me.apana.org.au>; from Herbert Xu on Tue, 23 Oct 2007 11:51:57 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> But your code differs significantly from Stephen's version.
> However, if it is correct it does look like a good improvement.
> 
> So please write a simple test program.  It can't that bad since
> there are only 65536 values to test :)

I think the code is simple enough to see immediately that it should
calculate the same checksum.  But I have written a short test program
to show this and tested it on i686 (gcc-4.2.2) and powerpc (gcc-3.4.5)
without optimization and with -O6.

BTW, shouldn't unsigned long be replaced by unsigned int to avoid
64-bit operations one some platforms?

urs


#include <stdio.h>

unsigned long f1(unsigned long sum)
{
    sum <<= 1;
    if (sum & 0x10000) {
	sum++;
	sum &= 0xffff;
    }
    return sum;
}

unsigned long f2(unsigned long sum)
{
    sum = ((sum & 0x8000)>>15) | ((sum & 0x7fff)<<1);
    return sum;
}

int main()
{
    unsigned long s;

    for (s = 0; s < 65536; s++) {
	if (f1(s) != f2(s) || f1(s) > 65535)
	    printf("%ld\n", s);
    }
    return 0;
}
