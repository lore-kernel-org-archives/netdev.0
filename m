From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] switchdev: clarify ndo_get_phys_port_name() formats
Date: Wed, 26 Jul 2017 13:54:12 -0400
Message-ID: <20170726175412.GB73972@C02RW35GFVH8.greyhouse.net>
References: <20170725051344.2040-1-jakub.kicinski@netronome.com>
 <20170725152241.GA71091@C02RW35GFVH8.dhcp.broadcom.net>
 <20170725152647.571d1af3@cakuba.netronome.com>
 <20170726014815.GA73972@C02RW35GFVH8.greyhouse.net>
 <20170725193447.3a714d61@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        simon.horman@netronome.com, davem@davemloft.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34156 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdGZRyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 13:54:17 -0400
Received: by mail-qt0-f195.google.com with SMTP id i19so7681862qte.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 10:54:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170725193447.3a714d61@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 07:34:47PM -0700, Jakub Kicinski wrote:
> On Tue, 25 Jul 2017 21:48:15 -0400, Andy Gospodarek wrote:
> > On Tue, Jul 25, 2017 at 03:26:47PM -0700, Jakub Kicinski wrote:
> > > On Tue, 25 Jul 2017 11:22:41 -0400, Andy Gospodarek wrote:  
> > > > On Mon, Jul 24, 2017 at 10:13:44PM -0700, Jakub Kicinski wrote:  
> > > > > We are still in position where we can suggest uniform naming
> > > > > convention for ndo_get_phys_port_name().  switchdev.txt file
> > > > > already contained a suggestion of how to name external ports.
> > > > > Since the use of switchdev for SR-IOV NIC's eswitches is growing,
> > > > > establish a format for ports of those devices as well.
> > > > > 
> > > > > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>    
> > > > 
> > > > This is a nice addition and I suspect there could be even more done to
> > > > update this file to cover the VF rep usage.
> > > >   
> > > > > ---
> > > > >  Documentation/networking/switchdev.txt | 14 +++++++++++---
> > > > >  1 file changed, 11 insertions(+), 3 deletions(-)
> > > > > 
> > > > > diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> > > > > index 3e7b946dea27..7c4b6025fb4b 100644
> > > > > --- a/Documentation/networking/switchdev.txt
> > > > > +++ b/Documentation/networking/switchdev.txt
> > > > > @@ -119,9 +119,17 @@ into 4 10G ports, resulting in 4 port netdevs, the device can give a unique
> > > > >  SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
> > > > >  	ATTR{phys_port_name}!="", NAME="swX$attr{phys_port_name}"
> > > > >  
> > > > > -Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
> > > > > -is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
> > > > > -would be sub-port 0 on port 1 on switch 1.
> > > > > +Suggested formats of the port name returned by ndo_get_phys_port_name are:
> > > > > + - pA     for external ports;
> > > > > + - pAsB   for split external ports;
> > > > > + - pfC    for PF ports (so called PF representors);
> > > > > + - pfCvfD for VF ports (so called VF representors).    
> > > > 
> > > > I hate to clutter this up, but might be also need to add:
> > > > 
> > > >  - pfCsB    for split PF ports (so called PF representors);
> > > >  - pfCsBvfD for split VF ports (so called VF representors).
> > > > 
> > > > or are we comfortable that these additions to the name for split ports
> > > > are implied?  
> > > 
> > > Hm..  What is a split PF port?  Splits happen on the physical port - see
> > > my rant on the thread this is a reply to ;)  PFs are PCIe functions,
> > > on the opposite side of the eswitch from the wires.  
> > 
> > I'm with you that I think there is value in separate netdevs to
> > represent "PFs, VFs and external ports/MACs" -- particularly for the
> > use-case you to create rules to control PF<->VF traffic.
> > 
> > So while I'm not saying it is a _great_ idea to support such a thing as
> > port-splitting of PFs, I suggested this addition as I'm not willing to restrict
> > such a design/implementation if a vendor or customer desired.  It seemed
> > useful to provde some guidance on how to name them -- even if we do not
> > like them.  :-)
> 
> If I understand you correctly split PF would be a situation where
> device has multiple port instances on the PCIe PF side?  IOW switch sees
> multiple endpoints on the PF side?  Let me attempt an ASCII diagram :)
> 
>                                                                            
>                     HOST A             ||          HOST B                  
>                                        ||                                  
>         PF A       | V | V | V | V     ||       PF B        | V | V | V               
>                    | F | F | F | F ... ||                   | F | F | F ...           
>  port A0 | port A1 | 0 | 1 | 2 | 3     || port B0 | port B1 | 0 | 1 | 2            
>                                        ||                                  
>              PCI Express link          ||        PCI Express link          
>         \      \      \  |   |   |          |        |      /   /   /         
>          \      \      \ |   |   |          |        |     /   /   /          
>           \______\______\'   |   |          |        '____/___/___/
>                          /---------------------------\                         
>                          |<<==========               |
>                          |             ==========>>  |
>                          |     SR-IOV e-switch       |                         
>                          |<<==========               |                         
>                          |             ==========>>  |                          
>                          \---------------------------/                     
>                               |        |         |                          
>                               |        |         |                          
>                                  ||         ||                               
>                           MAC 0  ||  MAC 1  || MAC 2                   
>                                  ||         ||                              
> 
> 
> Seems to be a valid configuration, perhaps this would actually be of
> some use in container workloads, especially if the ports could be
> instantiated at runtime in high numbers.  I would be cautious though
> with calling the instances splits.  The more different PFs look from
> MACs the better IMHO.  Do you actually have that problem today?
> 
> Is there any HW supported upstream which would benefit from this?  Could we
> decide on naming when we have an example implementation?  In theory
> nothing stops us from splitting VFs the same way.

Not that I know about right now.

> Another note on PF netdevs, perhaps the most awkward thing about them,
> is that they result in two netdevs being visible to the host.  This is
> not incorrect, since VFs if unassigned to VMs will end up creating an
> "actual" netdev and the switchdev port representor too, but it rubs
> some people the wrong way.  Which in turn makes those people try to not
> spawn separate netdevs, which is incorrect IMHO, and breaks down e.g.
> when the real netdev gets assigned to a namespace.

For me, the most awkward part of having a separate netdev for the PF and
the MAC is that is really not how things were thought about in the
nominal switching case (the non e-switch case).

Since idea behind switchdev when it was created was to make sure that
each front-panel port on a switch was represented by a netdev in the
kernel (and the 'CPU interface' was abstracted away by the driver) I was
always a bit uneasy about having a separate netdev allocated for the CPU
port when in the switching case it really wasn't necessary.

> I'm not sure if this clarifies my thinking, I have, however, seem to
> have drawn a moose :)

Which looks great, BTW.  The moose may turn out to be one of the major
benefits from this thread!
