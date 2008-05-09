From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100
	ss:esp 0068:c03a1e5c
Date: Fri, 9 May 2008 13:11:30 +0200
Message-ID: <20080509111130.GA7968@elte.hu>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV9DAC70A1FBBEECCCC05E4B2D30@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53165 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761259AbYEILLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 07:11:46 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV9DAC70A1FBBEECCCC05E4B2D30@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Marco Berizzi <pupilla@hotmail.com> wrote:

> Herbert Xu wrote:
> 
> > On Fri, May 09, 2008 at 11:50:00AM +0200, Marco Berizzi wrote:
> > >
> > > I have rebooted the two boxes with slub_debug.
> > > This is the output taken with network console.
> > > Herbert does it help you?
> > >
> > > BUG: unable to handle kernel paging request at 6b6b6b9f
> >
> > Unfortunately this just confirms that your skb has been freed
> > prematurely because 6b is the poison value.
> >
> > However, it doesn't point us at the offender.
> 
> :-((

you could try x86.git and enable CONFIG_KMEMCHECK, which catches all 
sorts of memory corruption bugs at its root:

  http://people.redhat.com/mingo/x86.git/README

it's for 32-bit currently, and depends on the following CONFIG details 
in your .config:

        depends on X86_32
        depends on !X86_USE_3DNOW
        depends on !CC_OPTIMIZE_FOR_SIZE
        depends on !DEBUG_PAGEALLOC && SLUB

note that CONFIG_DEBUG_PAGEALLOC=y will catch a few types of corruption 
too. Note that KMEMCHECK and DEBUG_PAGEALLOC are exclusive.

	Ingo
