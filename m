From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Tue, 25 Dec 2007 09:06:50 +0800
Message-ID: <20071225010650.GA29188@gondor.apana.org.au>
References: <E1J4TCz-0005L8-00@gondolin.me.apana.org.au> <4767DE91.9060803@nortel.com> <20071219011401.GA4585@gondor.apana.org.au> <47692AA1.20902@mail.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cbf123@mail.usask.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752712AbXLYBHX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47692AA1.20902@mail.usask.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 19, 2007 at 08:28:49AM -0600, Chris Friesen wrote:
> 
> I've included the traces below, they're pretty long.  I don't know 
> enough about the netlink format to trace the responses, but I did notice 
> one interesting thing.
> 
> In the "ip neigh show" case the "bond2" entry isn't printed out, but I 
> can see the string "bond2" in the recvmsg() call so it looks like the 

Actually bond2 isn't in the recvmsg, it's just that strace is
printing out the complete content of the buffer which happenes
to include bond2.

I've verified that the first recvmsg indeed does not contain the
bond2 address at all.  Instead of the first 3 IPv4 records it has
3 IPv6 records.  So we seem to have a kernel problem here.

However, too many changes have been made in this area since 2.6.14
for it to be worthwhile for me to debug this any further until you
manage to reproduce it with the current kernel.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
