From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon, 3 Oct 2016 17:50:33 +0100
Message-ID: <20161003165032.GB15313@leverpostej>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
 <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
 <20161003154624.GG7632@leverpostej>
 <87oa319zv8.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:44208 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbcJCQvD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 12:51:03 -0400
Content-Disposition: inline
In-Reply-To: <87oa319zv8.fsf@belgarion.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 03, 2016 at 06:11:23PM +0200, Robert Jarzmik wrote:
> Mark Rutland <mark.rutland@arm.com> writes:
> 
> > On Mon, Oct 03, 2016 at 11:05:53AM +0200, Robert Jarzmik wrote:
> >> Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
> >> which must be aligned on 32 bits addresses.
> >> 
> >> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> >> ---
> >>  Documentation/devicetree/bindings/net/smsc911x.txt | 2 ++
> >>  1 file changed, 2 insertions(+)
> >> 
> >> diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> >> index 3fed3c124411..224965b7453c 100644
> >> --- a/Documentation/devicetree/bindings/net/smsc911x.txt
> >> +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> >> @@ -13,6 +13,8 @@ Optional properties:
> >>  - reg-io-width : Specify the size (in bytes) of the IO accesses that
> >>    should be performed on the device.  Valid value for SMSC LAN is
> >>    2 or 4.  If it's omitted or invalid, the size would be 2.
> >> +- reg-u16-align4 : Boolean, put in place the workaround the force all
> >> +  		   u16 writes to be 32 bits aligned
> >
> > This property name and description is confusing.
> >
> > How exactly does this differ from having reg-io-width = <4>, which is
> > documented immediately above?
> 
> reg-io-width specifies the IO size, ie. how many data lines are physically
> connected from the system bus to the lan adapter.
> 
> reg-u16-align4 tells that a specific hardware doesn't support 16 bit writes not
> being 32 bits aligned, or said differently that a "store" 16 bits wide on an
> address of the format 4*n + 2 deserves a special handling in the driver, while a
> store 16 bits wide on an address of the format 4*n can follow the simple casual
> case.

If I've understood correctly, effectively the low 2 address lines to the
device are hard-wired to zero, e.g. a 16-bit access to 4*n + 2 would go
to 4*n + 0 on the device? Or is the failure case distinct from that?

Do we have other platforms where similar is true? e.g. u8 accesses
requiring 16-bit alignment?

Thanks,
Mark.
