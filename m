From: Paul Moore <paul.moore@hp.com>
Subject: Re: Labeled Networking Requirements and Design (formerly RE: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in  MLS environments)
Date: Mon, 26 Jun 2006 21:53:47 -0400
Message-ID: <200606262153.48251.paul.moore@hp.com>
References: <44A0684D.9080904@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	davem@davemloft.net, sds@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:54229 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1030604AbWF0Bx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:53:59 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44A0684D.9080904@trustedcs.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 June 2006 7:05 pm, Venkat Yekkirala wrote:
> USER REQUIREMENTS:
>
> The broad user requirements for labeled networking would be that of
> information labeling and flow control. Specifically,
>
> 1. Data labeling:
> 	a. data must be labeled where it originates.
> 	b. data must retain that label (or its interpretation in a given domain)
> 	   when conveyed in a trustworthy manner.

{snip}

> PROPOSED DESIGN:
>
> Given the above requirements the following design is proposed:
>
> On the outbound (OTBND):
>
> The following applies to locally-generated (OUTPUT) as well as forwarded
> (FORWARD) traffic.
>
> 1.	OUTPUT ONLY:
> 	a. Set secmark of the packet to the label of the socket unless its a
> 	   datagram, the process is privileged and is allowed to specify
> 	   a different label for the datagram per policy (R1a, R3a, R3c).
>
> 	b. If there's no real socket to take the label from, and this packet is
> 	   in response to a received packet, use the level from the received
> 	   packet, taking the TE portion of the context from the pseudo-socket
> 	   on whose behalf the packet is being sent.
>

Keeping in mind (R1a), I wonder if it makes more sense for (OTBND1a) to take 
the label of the process/domain which sends the data to the socket?  After 
all, the process/domain is the "origin" of the data.  This seems to be 
particularly important in the case of fork()-then-exec() where you could have 
a socket created at a different context from the domain currently writing to 
it.

-- 
paul moore
linux security @ hp
