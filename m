From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Mon, 7 Jul 2014 13:18:43 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407071306080.5433@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>        <20140702.182807.1245632778216212860.davem@davemloft.net>        <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>        <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
        <1404356734.14741.18.camel@joe-AO725>        <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>        <1404364565.14741.26.camel@joe-AO725>        <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>        <1404368746.14741.36.camel@joe-AO725>
        <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>        <1404576420.6384.41.camel@joe-AO725>        <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>        <1404583739.6384.51.camel@joe-AO725>       
 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>        <1404585099.6384.53.camel@joe-AO725> <20140707120152.CF82BC40921@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140707120152.CF82BC40921@trevor.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 Jul 2014, Grant Likely wrote:

> > > > I don't think %#p is valid so it
> > > > shouldn't have been set by #.
> > > 
> > >  Huh?  As recently as last Wednesday you pointed me at the specific commit 
> > > from Grant that made it valid (GCC format complaints aside).
> > 
> > Those gcc complaints are precisely the thing
> > that makes it invalid.
> 
> That's the most inane reason ever for saying something is invalid. "The
> tool doesn't recognise it, there for it is invalid?" Seriously?
> 
> Tools are just tools. They aren't the source of what is valid/invalid,
> they only report on what we as engineers have told them to do, because
> *we* define what should be valid/invalid.
> 
> If you've got a real reason that explains *why* the tool rejects that
> construct, then I'd be happy to hear it, but otherwise that argument
> makes no sense.

 GCC rejects it, because its `printf' format attribute expects format 
specifiers according to ISO C and its formatted input/output functions.  
The syntax of our `printk' is however different, not only for %#p, so I 
agree it's GCC that acts incompatibly and not our design being wrong.  I 
have therefore offered a solution (though not an implementation right now, 
sorry; I'm not even set up to start such development right away) to 
introduce a `linux_printk' format attribute to GCC that would match our 
requirements.

 FAOD I'm in favour to retaining `#' with %p, but then making it 
consistent across variants such as %pad vs %#pad.  This does not preclude 
or require adding `linux_printk' to GCC in the future.

  Maciej
