From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 19:31:16 -0400
Message-ID: <487D3344.8000804@garzik.org>
References: <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org> <20080715223626.GA10532@redhat.com> <487D2AEE.8030309@garzik.org> <20080715231457.GA15266@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33211 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754612AbYGOXb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 19:31:29 -0400
In-Reply-To: <20080715231457.GA15266@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> On Tue, Jul 15, 2008 at 06:55:42PM -0400, Jeff Garzik wrote:
> 
>  > >  > * [optional] would prefer CONFIG_8139TOO_PIO be handled at compile time, 
>  > >  > by changing the initialized value
>  > > 
>  > > This bit should be taken care of in rtl8139_init_module() at the bottom..
>  > > 
>  > > +       /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
>  > > +#ifdef CONFIG_8139TOO_PIO
>  > > +       use_io = 1;
>  > > +#endif
>  > 
>  > Right, I was saying I prefer simply to set the initialized value 
>  > appropriately, and avoid the extra code dollup during module load.
> 
> Oh, you mean something like..
> 
> static int use_io = CONFIG_8139TOO_PIO;
> 
> ?

Sorry for not being specific.  I would have guessed the uglier

	#ifdef CONFIG_8139TOO_PIO
		static int use_io = 1;
	#else
		static int use_io;
	#endif

since CONFIG_8139TOO_PIO doesn't convert to a 1 or 0 neatly in C AFAIK?


But, overall, yes.  You get the general idea.

	Jeff



