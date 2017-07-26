From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] switchdev: clarify ndo_get_phys_port_name() formats
Date: Tue, 25 Jul 2017 21:48:15 -0400
Message-ID: <20170726014815.GA73972@C02RW35GFVH8.greyhouse.net>
References: <20170725051344.2040-1-jakub.kicinski@netronome.com>
 <20170725152241.GA71091@C02RW35GFVH8.dhcp.broadcom.net>
 <20170725152647.571d1af3@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        simon.horman@netronome.com, davem@davemloft.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34121 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdGZBsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 21:48:19 -0400
Received: by mail-qk0-f195.google.com with SMTP id q66so14274694qki.1
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 18:48:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170725152647.571d1af3@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:26:47PM -0700, Jakub Kicinski wrote:
> On Tue, 25 Jul 2017 11:22:41 -0400, Andy Gospodarek wrote:
> > On Mon, Jul 24, 2017 at 10:13:44PM -0700, Jakub Kicinski wrote:
> > > We are still in position where we can suggest uniform naming
> > > convention for ndo_get_phys_port_name().  switchdev.txt file
> > > already contained a suggestion of how to name external ports.
> > > Since the use of switchdev for SR-IOV NIC's eswitches is growing,
> > > establish a format for ports of those devices as well.
> > > 
> > > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>  
> > 
> > This is a nice addition and I suspect there could be even more done to
> > update this file to cover the VF rep usage.
> > 
> > > ---
> > >  Documentation/networking/switchdev.txt | 14 +++++++++++---
> > >  1 file changed, 11 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> > > index 3e7b946dea27..7c4b6025fb4b 100644
> > > --- a/Documentation/networking/switchdev.txt
> > > +++ b/Documentation/networking/switchdev.txt
> > > @@ -119,9 +119,17 @@ into 4 10G ports, resulting in 4 port netdevs, the device can give a unique
> > >  SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
> > >  	ATTR{phys_port_name}!="", NAME="swX$attr{phys_port_name}"
> > >  
> > > -Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
> > > -is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
> > > -would be sub-port 0 on port 1 on switch 1.
> > > +Suggested formats of the port name returned by ndo_get_phys_port_name are:
> > > + - pA     for external ports;
> > > + - pAsB   for split external ports;
> > > + - pfC    for PF ports (so called PF representors);
> > > + - pfCvfD for VF ports (so called VF representors).  
> > 
> > I hate to clutter this up, but might be also need to add:
> > 
> >  - pfCsB    for split PF ports (so called PF representors);
> >  - pfCsBvfD for split VF ports (so called VF representors).
> > 
> > or are we comfortable that these additions to the name for split ports
> > are implied?
> 
> Hm..  What is a split PF port?  Splits happen on the physical port - see
> my rant on the thread this is a reply to ;)  PFs are PCIe functions,
> on the opposite side of the eswitch from the wires.

I'm with you that I think there is value in separate netdevs to
represent "PFs, VFs and external ports/MACs" -- particularly for the
use-case you to create rules to control PF<->VF traffic.

So while I'm not saying it is a _great_ idea to support such a thing as
port-splitting of PFs, I suggested this addition as I'm not willing to restrict
such a design/implementation if a vendor or customer desired.  It seemed
useful to provde some guidance on how to name them -- even if we do not
like them.  :-)
