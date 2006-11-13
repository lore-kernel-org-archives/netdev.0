From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Mon, 13 Nov 2006 07:56:52 +0000
Message-ID: <200611130756.52728@strip-the-willow>
References: <200611101609.21333@strip-the-willow> <20061110093715.0aadd791@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:31142 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1754247AbWKMH5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 02:57:24 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061110093715.0aadd791@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Stephen Hemminger:
|  On Fri, 10 Nov 2006 16:09:20 +0000
|  Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  
|  > [NET/IPv4]: Support for the UDP-Lite protocol (RFC 3828)
|  > 
|  > This adds support for UDP-Lite to the IPv4 stack, provided as an extension
|  > to the existing UDPv4 code:
|  > 	* generic routines are all located in net/ipv4/udp.c
|  > 	* UDP-Lite specific routines are in net/ipv4/udplite.c
|  > 	* MIB/statistics support in /proc/net/snmp and /proc/net/udplite
|  > 	* shared API with extensions for partial checksum coverage
|  > 	* consolidation of shared code
|  > 
|  > 
|  
|  This code is does too much inlining (like existing network code).
|  Should it be made configurable?
That is a late question for a patch which has been in a RFC phase for several months.
This patch had been submitted repeatedly for RFC between middle of September ... end 
of October.

It used to be configurable and it also used to be much more bloated:

 	``The in-lining is a feature, not a bug!''

Reason: If you look at udplite.c (which is, despite #including, a fully self-contained
        protocol module), the inline functions all call generic code from udp.c. If you
        then look back at udp.c, you see that UDP almost does the same. What you have here
        is two protocols for the price of one; the inlines work as wrappers for both UDP
        and UDP-Lite. And considerable amount of extracting and minimising went into making
        it that way.

Before: The patch used to be separate and was an `enormous mass of code reduplication'. 
        Imagine udp.c reduplicated and modified to run UDP-Lite: then you have two highly
        similar code files, over 90% of code reduplication (bad ... very bad).

Is there someone else supporting `make UDP-Lite' configurable -- in the end I am being asked
to re-implement a feature I was asked to remove a couple of months ago. It is not a problem
to do this, but this code has cost a lot of work and I would like to finally see it in 2.6.20.

Gerrit
