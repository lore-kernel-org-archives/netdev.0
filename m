From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Thu, 19 Feb 2009 21:53:58 +0800
Message-ID: <20090219135358.GA11319@gondor.apana.org.au>
References: <loom.20090218T192451-89@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Huang <jamesclhuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44228 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757058AbZBSNyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 08:54:04 -0500
Content-Disposition: inline
In-Reply-To: <loom.20090218T192451-89@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Huang <jamesclhuang@gmail.com> wrote:
> Hi Herbert,

Please cc me if you're going to address the email to me :)

>    Any idea when this LRO restructuring work will be done? 

The target is to get GRO into 2.6.30, and have all LRO drivers
converted by 2.6.31.

> Making LRO available even when ip forwarding is enabled will significantly 
> improve performace of network appliances in the data path.  

I'd like to see more performance data on the forwarding side.
The act of aggregation isn't exactly free so it very much depends
on what you're forwarding.

The driver for all this work is bridging used for virtualisation
where the data is very likely to be mergeable.

> I have some questions on this: 
> (1) Based on the emails in this thread, I suppose you are going to keep the 
> original length of each segment you coalesced into the big packet and use that 
> info to segment the big packet on the output path.  In case the packet was 
> modified by an appliance in the path and the total length is changed (e.g. NAT 
> on ftp control packets), should the corresponding segment length info also get 
> updated?  This same question also applies to the checksums.

If packet length changes due to NAT then we're no loner bound
by the end-to-end restriction so we can do whatever we want.

For GRO we treat it in exactly the same way as a GSO packet that
undergoes NAT.  That is, NAT just sees a very large IP packet and
does what it has to do, and on final output we resegment the packet.

> (2) Do you make sure all of the segments to be coalesced have the same DF bit?

Yes.

> (3) I think bridged packets should not be LROed. Whether a packet is bridged 
> or not can be based on the L2 MAC destination address.  Is this how it is done?

We currently require the Ethernet header to be identical.

> (4) Does LRO work only for IPv4?  Any plan to extend it to support IPv6?

IPv6 is supported.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
