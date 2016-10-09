From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Sat, 8 Oct 2016 20:28:58 -0500
Message-ID: <20161009012858.GL18158@rob-hp-laptop>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
 <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
 <20161003154624.GG7632@leverpostej>
 <20161003160913.GQ1041@n2100.armlinux.org.uk>
 <20161003164228.GA15313@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Nicolas Pitre <nico@fluxnic.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36503 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753100AbcJIBbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 21:31:24 -0400
Content-Disposition: inline
In-Reply-To: <20161003164228.GA15313@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 03, 2016 at 05:42:29PM +0100, Mark Rutland wrote:
> On Mon, Oct 03, 2016 at 05:09:13PM +0100, Russell King - ARM Linux wrote:
> > Please note that the binding doc for smsc,lan91c111.txt is slightly wrong
> > on two counts:
> > 
> > 1) compatible property:
> > 
> > compatible = "smsc,lan91c111";
> > 
> > vs the code:
> > 
> > static const struct of_device_id smc91x_match[] = {
> >         { .compatible = "smsc,lan91c94", },
> >         { .compatible = "smsc,lan91c111", },
> >         {},
> > };
> > MODULE_DEVICE_TABLE(of, smc91x_match);
> > 
> > So the binding document needs to mention that smsc,lan91c94 is a valid
> > compatible for this device.
> 
> Yes, it should.
> 
> > 2) reg-io-width property:
> > 
> > - reg-io-width : Mask of sizes (in bytes) of the IO accesses that
> >   are supported on the device.  Valid value for SMSC LAN91c111 are
> >   1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
> >   16-bit access only.
>  
> > Moreover, look at the property name vs the binding description.  It's
> > property name says it's a width, but the description says it's a mask
> > of sizes - these really aren't the same thing.  Once you start
> > specifying these other legal masks, it makes a nonsense of the "width"
> > part of the name.  It's too late to try and fix this now though.
> 
> Indeed, as-is this is nonsense. :(
> 
> The best we can do here is to add a big fat notice regarding the
> misnaming; adding a new property is only giong to cause more confusion.

Just fix the text here removing the mask part. This is a common property 
and not a mask. The rest saying 1, 2, 4 being valid is correct. There 
are no occurences using this as a mask in kernel dts files either.

> 
> > The binding document really needs to get fixed - I'll try to cook up a
> > patch during this week to correct these points, but it probably needs
> > coordination if others are going to be changing this as well.
> 
> Thanks for handling both of these.
> 
> Given the historical rate of change of the binding document, I suspect
> the stuff for pxa platforms is going to be the only potential conflict.
> 
> Either all of that can go via the DT tree (independent of any new code),
> or we can ack the whole lot and it can all go via the net tree in one
> go.
> 
> Thanks,
> Mark.
