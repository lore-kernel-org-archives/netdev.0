From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Mon, 13 Nov 2006 16:49:09 -0800 (PST)
Message-ID: <20061113.164909.35016870.davem@davemloft.net>
References: <XMMS.LNX.4.64.0611101122520.15046@d.namei>
	<XMMS.LNX.4.64.0611101126150.15046@d.namei>
	<39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34699
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933270AbWKNAtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:49:01 -0500
To: arnaldo.melo@gmail.com
In-Reply-To: <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 10 Nov 2006 16:32:16 -0200

> On 11/10/06, James Morris <jmorris@namei.org> wrote:
> > On Fri, 10 Nov 2006, James Morris wrote:
> >
> > > I wonder if this facility can be integrated more generally into the kernel
> > > protocol which people are developing.
> >
> > Ugh, editor screwup.  That was meant to be
> >
> > I wonder if this facility can be integrated more generally into the kernel
> > as a kernel hacking option, as this is not the only protocol which people
> > are developing.
> >
> 
> See:
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
> 
> This one requires a bit more thinking, so I'm postponing it for now to
> get the simple bits in Gerrit's patch queue cherrypicked and sent for
> Dave.

One possible way to handle this is to flag certain sockets such that
no refrence counting is done for them against the module.  It is
an indication that the module will take care of such sockets on
cleanup.

It seems that this would limit the cost to a test at socket create
and destroy time.
