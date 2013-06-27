From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 2/2] netdev: octeon_mgmt: Fix structure layout for
 little-endian.
Date: Thu, 27 Jun 2013 12:40:48 +0200
Message-ID: <20130627104048.GR7171@linux-mips.org>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
 <1371688820-4585-3-git-send-email-ddaney.cavm@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B729B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linux-mips@linux-mips.org,
	David Daney <david.daney@cavium.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:57084 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab3F0KlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 06:41:00 -0400
Received: from localhost.localdomain ([127.0.0.1]:52033 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6824764Ab3F0Kk7eg5j7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jun 2013 12:40:59 +0200
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B729B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 10:47:57AM +0100, David Laight wrote:

> > The C ABI reverses the bitfield fill order when compiled as
> > little-endian.
> 
> No - it is completely implementation defined.
> The general concensus is not to use bitfields if you
> care at all about the bit assignments.

FWIW, bitfields often alow things to be expressed more nicely.  Just the
endian-dependent definition suck, so I came up with this little hack
for arch/mips/include/uapi/asm/inst.h:

#ifdef __MIPSEB__
#define BITFIELD_FIELD(field, more)                                     \
        field;                                                          \
        more

#elif defined(__MIPSEL__)

#define BITFIELD_FIELD(field, more)                                     \
        more                                                            \
        field;
#endif

struct i_format {                       /* signed immediate format */
        BITFIELD_FIELD(unsigned int opcode : 6,
        BITFIELD_FIELD(unsigned int rs : 5,
        BITFIELD_FIELD(unsigned int rt : 5,
        BITFIELD_FIELD(signed int simmediate : 16,
        ;))))
};

  Ralf
