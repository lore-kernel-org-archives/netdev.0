From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
Date: Tue, 27 Mar 2007 22:51:53 +0200
Message-ID: <460983E9.5040005@trash.net>
References: <20070327053821.GA23596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934163AbXC0UxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 16:53:14 -0400
In-Reply-To: <20070327053821.GA23596@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Dave:
> 
> [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
> 
> Right now Xen has a horrible hack that lets it forward packets with
> partial checksums.  One of the reasons that CHECKSUM_PARTIAL and
> CHECKSUM_COMPLETE were added is so that we can get rid of this hack
> (where it creates two extra bits in the skbuff to essentially mirror
> ip_summed without being destroyed by the forwarding code).
> 
> I had forgotten that I've already gone through all the deivce drivers
> last time around to make sure that they're looking at ip_summed ==
> CHECKSUM_PARTIAL rather than ip_summed != 0 on transmit.  In any case,
> I've now done that again so it should definitely be safe.
> 
> Unfortunately nobody has yet added any code to update CHECKSUM_COMPLETE
> values on forward so we I'm setting that to CHECKSUM_NONE.  This should
> be safe to remove for bridging but I'd like to check that code path
> first.
> 
> So here is the patch that lets us get rid of the hack by preserving
> ip_summed (mostly) on forwarded packets.


Just wondering, how does Xen know whether a packet will be forwarded?
The input path doesn't seem to deal with CHECKSUM_PARTIAL correctly,
ip_defrag for example resets them to CHECKSUM_NONE, so further checks
will fail, others seem to either ignore them or handle them together
with CHECKSUM_NONE.

