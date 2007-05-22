From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Wed, 23 May 2007 09:12:02 +1000
Message-ID: <20070522231202.GA17720@gondor.apana.org.au>
References: <E1Hq2kM-0000ID-00@gondolin.me.apana.org.au> <OF9ABCD08D.2CD1B193-ON872572E3.007A6FC1-882572E3.007ACE1A@us.ibm.com> <20070522.153636.115911096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xma@us.ibm.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rdreier@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4848 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756616AbXEVXM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:12:27 -0400
Content-Disposition: inline
In-Reply-To: <20070522.153636.115911096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 22, 2007 at 03:36:36PM -0700, David Miller wrote:
> 
> > > Yep, for any NIC that supports SG but not TSO then software GSO will
> > > be a big win.  When the NIC doesn't support SG then the win is mostly
> > > offset by the need to copy the packet again.

...
 
> SKB's from TSO are composed of discontiguous page chunks represented
> by the skb_shared_info() array.  These can come either from sendmsg()
> user data (which the kernel fills into a per-socket data page which is
> reallocated once filled), or from sendfile() page cache pages.

Yes sendmsg() is the case where it's almost even whether GSO is
turned on or off because GSO does an extra copy which offsets the
win in reduced per-packet cost.

For sendfile() it's still a win though since we have to copy it
anyway and doing it in GSO avoids the per-packet cost.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
