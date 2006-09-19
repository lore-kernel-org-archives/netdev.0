From: Paul Mackerras <paulus@samba.org>
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 09:27:11 +1000
Message-ID: <17680.31951.464796.856782@cargo.ozlabs.ibm.com>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
	<20060919184243.GL29167@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, akpm@osdl.org,
	ppc-dev <linuxppc-dev@ozlabs.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33201 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1750782AbWISX2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 19:28:36 -0400
To: linas@austin.ibm.com (Linas Vepstas)
In-Reply-To: <20060919184243.GL29167@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas writes:

> The rest of this patch might indeed be correct, but the above comment 
> bothers me. The "ns" versions of routines are supposed to be
> non-byte-swapped versions of the insl/outsl routines (which would
> byte-swap on big-endian archs such as powerpc.)

If it were true that in/outsw and in/outsl were actually used to
transfer arrays of 16-bit data items or 32-bit data items to/from an
I/O device, I would agree with you, but they aren't.  They are
universally used to transfer arrays of bytes, with the optimization of
doing so 2 or 4 bytes at a time.  That is why in/outsw and in/outsl
don't (and shouldn't) do byte swapping.

Paul.
