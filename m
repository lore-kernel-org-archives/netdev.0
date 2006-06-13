From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] [2.6.17-rc6] Section mismatch in drivers/net/ne.o
 during modpost
Date: Tue, 13 Jun 2006 08:11:39 -0700
Message-ID: <20060613081139.ea605d64.rdunlap@xenotime.net>
References: <200606110051.k5B0pLBI010621@harpo.it.uu.se>
	<10735.1150176929@kao2.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikpe@it.uu.se, akpm@osdl.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:29875 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751130AbWFMPI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 11:08:56 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 08:08:51 -0700
To: Keith Owens <kaos@ocs.com.au>
In-Reply-To: <10735.1150176929@kao2.melbourne.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jun 2006 15:35:29 +1000 Keith Owens wrote:

> Mikael Pettersson (on Sun, 11 Jun 2006 02:51:21 +0200 (MEST)) wrote:
> >On Sat, 10 Jun 2006 12:13:35 -0700, Randy.Dunlap wrote:
> >>On Sat, 10 Jun 2006 14:11:42 +0200 (MEST) Mikael Pettersson wrote:
> >>
> >>> While compiling 2.6.17-rc6 for a 486 with an NE2000 ISA ethernet card, I got:
> >>> 
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x158) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x176) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x183) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x1ea) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x251) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x266) and 'ne_block_input'
> >>> WARNING: drivers/net/ne.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x29b) and 'ne_block_input'
> >>> 
> >>> Not sure how serious this is; the driver seems to work fine later on.
> >>
> >>Doesn't look serious.  init_module() is not __init, but it calls
> >>some __init functions and touches some __initdata.
> >>
> >>BTW, I would be happy to see some consistent results from modpost
> >>section checking.  I don't see all of these warnings (I see only 1)
> >>when using gcc 3.3.6.  What gcc version are you using?
> >>Does that matter?  (not directed at anyone in particular)
> >
> >The messages above are from when I used gcc-4.1.1.
> >With gcc-3.2.3 I only see a single warning.
> 
> Probably over enthusiastic gcc inlining.  gcc 4 will inline functions
> that are not declared as inline.  That is not so bad, except that some
> versions of gcc will ignore a mismatch in function attributes and
> inline a __init function into normal text, generating additional
> section mismatches.  For a specific example, see
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=113824309203482&w=2

Yes, I am seeing lots of that.  :(

---
~Randy
