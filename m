From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [Fwd: pcmcia ether drivers can't be unloaded]
Date: Sat, 7 Aug 2004 12:09:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040807120943.A2805@flint.arm.linux.org.uk>
References: <41068BEF.7010200@pobox.com> <20040727233614.B30782@flint.arm.linux.org.uk> <20040727171929.17858c7b.davem@redhat.com> <20040728165024.A8475@flint.arm.linux.org.uk> <20040728085419.773c4d94.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, shemminger@osdl.org, netdev@oss.sgi.com, greg@kroah.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040728085419.773c4d94.davem@redhat.com>; from davem@redhat.com on Wed, Jul 28, 2004 at 08:54:19AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2004 at 08:54:19AM -0700, David S. Miller wrote:
> On Wed, 28 Jul 2004 16:50:24 +0100
> Russell King <rmk@arm.linux.org.uk> wrote:
> 
> > On Tue, Jul 27, 2004 at 05:19:29PM -0700, David S. Miller wrote:
> > > I totally disagree.  This is a bogus argument for two reasons:
> > 
> > You may disagree, that is your option.  However, facts are facts -
> > this is how the PCMCIA layer currently works, and short of rewriting
> > the whole damned thing it isn't going to change.  Sorry.
> 
> Stephen offered a solution, moving this stray refcount into a toplevel
> pcmcia bus type object.  We are not constrained by how the PCMCIA layer
> currently works, just as we were not constrained a year ago by how the
> generic network device handling worked when it was totally broken in
> this area.  We just fixed it instead of whining.

Right, I now have sufficient time to investigate and provide a proper
response.

The reason PCMCIA modules _as a whole_ (ie, not limited to just PCMCIA
network drivers) are not unloadable while in use is that:

(1) the PCMCIA subsystem keeps references to structures inside the
    PCMCIA card driver module while the driver is bound (by the
    userspace daemon) to the PCMCIA card.

(2) the userspace daemon, cardmgr, keeps track of which PCMCIA
    card driver modules are loaded, and loads and unloads them
    as necessary.

Short of rearchitecting the way the PCMCIA userspace daemon works, I
don't see an easy fix for this.  Therefore, as I've already said, the
current behaviour stands for 2.6.  PCMCIA is _far_ too fragile to
risk doing a rewrite to get the locking and structure refcounting
rules correct overnight.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
