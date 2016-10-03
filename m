From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon, 3 Oct 2016 17:42:29 +0100
Message-ID: <20161003164228.GA15313@leverpostej>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
 <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
 <20161003154624.GG7632@leverpostej>
 <20161003160913.GQ1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161003160913.GQ1041-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 03, 2016 at 05:09:13PM +0100, Russell King - ARM Linux wrote:
> Please note that the binding doc for smsc,lan91c111.txt is slightly wrong
> on two counts:
> 
> 1) compatible property:
> 
> compatible = "smsc,lan91c111";
> 
> vs the code:
> 
> static const struct of_device_id smc91x_match[] = {
>         { .compatible = "smsc,lan91c94", },
>         { .compatible = "smsc,lan91c111", },
>         {},
> };
> MODULE_DEVICE_TABLE(of, smc91x_match);
> 
> So the binding document needs to mention that smsc,lan91c94 is a valid
> compatible for this device.

Yes, it should.

> 2) reg-io-width property:
> 
> - reg-io-width : Mask of sizes (in bytes) of the IO accesses that
>   are supported on the device.  Valid value for SMSC LAN91c111 are
>   1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
>   16-bit access only.
 
> Moreover, look at the property name vs the binding description.  It's
> property name says it's a width, but the description says it's a mask
> of sizes - these really aren't the same thing.  Once you start
> specifying these other legal masks, it makes a nonsense of the "width"
> part of the name.  It's too late to try and fix this now though.

Indeed, as-is this is nonsense. :(

The best we can do here is to add a big fat notice regarding the
misnaming; adding a new property is only giong to cause more confusion.

> The binding document really needs to get fixed - I'll try to cook up a
> patch during this week to correct these points, but it probably needs
> coordination if others are going to be changing this as well.

Thanks for handling both of these.

Given the historical rate of change of the binding document, I suspect
the stuff for pxa platforms is going to be the only potential conflict.

Either all of that can go via the DT tree (independent of any new code),
or we can ack the whole lot and it can all go via the net tree in one
go.

Thanks,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
