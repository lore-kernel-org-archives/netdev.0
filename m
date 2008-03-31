From: Greg KH <greg@kroah.com>
Subject: Re: [BUILD_FAILURE] linux-next: Tree for March 31 build fails with
	CONFIG_SLICOSS=y
Date: Mon, 31 Mar 2008 08:55:54 -0700
Message-ID: <20080331155554.GE3696@kroah.com>
References: <20080331181118.7964d4a9.sfr@canb.auug.org.au> <47F0E456.5080201@linux.vnet.ibm.com> <20080401003110.d4834b07.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>,
	Christopher Harrer <charrer@alacritech.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56253 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbYCaPud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 11:50:33 -0400
Content-Disposition: inline
In-Reply-To: <20080401003110.d4834b07.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2008 at 12:31:10AM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Strike two!  Again, these drivers need to build (or not try to build) for
> all architectures ... Its out until you tell me the above is true.
> 
> #if defined(CONFIG_X86_64)
>         hcmd->cmdsize = (ulong32) ((((ulong64) & ihcmd->u.slic_buffers.bufs[1] -
>                                      (ulong64) hcmd) + 31) >> 5);
> #elif defined(CONFIG_X86)
>         hcmd->cmdsize = ((((ulong32) & ihcmd->u.slic_buffers.bufs[1] -
>                            (ulong32) hcmd) + 31) >> 5);
> #else
>         Stop Compilation;

Ah, missed that one, that's why it built on my machines (x86-64 and
i386), but would die on anything else.  That test is just wrong, I'll
fix it up to get it to build on all arches (doesn't mean it will run
though, it assumes that port io is memory mapped flat on all machines
and still needs a lot of work to be fixed.

thanks,

greg k-h
