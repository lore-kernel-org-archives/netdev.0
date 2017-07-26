From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC] switchdev: clarify ndo_get_phys_port_name() formats
Date: Wed, 26 Jul 2017 01:13:10 -0700
Message-ID: <20170726011310.5db489ed@cakuba.netronome.com>
References: <20170724214521.75bf5857@cakuba.netronome.com>
        <20170725051344.2040-1-jakub.kicinski@netronome.com>
        <20170726054840.GA1845@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        simon.horman@netronome.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:36272 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751441AbdGZINV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 04:13:21 -0400
In-Reply-To: <20170726054840.GA1845@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jul 2017 07:48:40 +0200, Jiri Pirko wrote:
> Tue, Jul 25, 2017 at 07:13:44AM CEST, jakub.kicinski@netronome.com wrote:
> >We are still in position where we can suggest uniform naming
> >convention for ndo_get_phys_port_name().  switchdev.txt file
> >already contained a suggestion of how to name external ports.
> >Since the use of switchdev for SR-IOV NIC's eswitches is growing,
> >establish a format for ports of those devices as well.
> >
> >Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> >---
> > Documentation/networking/switchdev.txt | 14 +++++++++++---
> > 1 file changed, 11 insertions(+), 3 deletions(-)
> >
> >diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> >index 3e7b946dea27..7c4b6025fb4b 100644
> >--- a/Documentation/networking/switchdev.txt
> >+++ b/Documentation/networking/switchdev.txt
> >@@ -119,9 +119,17 @@ into 4 10G ports, resulting in 4 port netdevs, the device can give a unique
> > SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
> > 	ATTR{phys_port_name}!="", NAME="swX$attr{phys_port_name}"
> > 
> >-Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
> >-is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
> >-would be sub-port 0 on port 1 on switch 1.
> >+Suggested formats of the port name returned by ndo_get_phys_port_name are:
> >+ - pA     for external ports;
> >+ - pAsB   for split external ports;
> >+ - pfC    for PF ports (so called PF representors);
> >+ - pfCvfD for VF ports (so called VF representors).  
> 
> I think it would make sense if the driver would just fill-up a struct in
> the ndo call and core would generate the string.

I do like the idea of core generating the string.  I have a temptation
to try to involve devlink in this somehow, since port id and split info
is already available there.  Perhaps that would only overcomplicate
things.

The other question is: can we remove the option to generate an arbitrary
string completely?  I think Or and mlx5 folks may object since it would
mean mlx5 VF repr names would change.
