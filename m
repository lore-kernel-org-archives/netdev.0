From: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Disabling autoneg and enforcing speed/duplex
Date: Thu, 6 Feb 2014 08:50:26 -0600
Message-ID: <CAL_JsqJ=Me+MKF8DGMsh=0y4VLmekUHD7KgmQDkCpDEuKVOT+w@mail.gmail.com>
References: <52F3796B.8050809@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Brunck, Holger" <Holger.Brunck-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
To: Gerlando Falauto <gerlando.falauto-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52F3796B.8050809-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 6, 2014 at 6:00 AM, Gerlando Falauto
<gerlando.falauto-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org> wrote:
> Hi,
>
> I'm using the Kirkwood Ethernet controller (mv643xx_eth.c) with a Marvell
> 88E3018 PHY which needs to be set in forced 100Base-TX mode.
>
> Thanks to Sebastian's addition of DT support to the ethernet driver, I can
> easily set speed and duplex within the ethernet's port node, therefore
> leaving the phy unmanaged -- this works fine (I guess this mode is set on
> the phy by the bootloader or by strap settings).
>
> However, this PHY has an erratum whose workaround requires some registers be
> written -- I believe the natural solution would be to start managing the PHY
> (i.e. set "phy-handle") and implement the proper workaround within
> drivers/net/phy/marvell.c. Making the PHY managed does however enable
> autoneg and therefore break everything.
>
> Which brings me to my question: shouldn't there be a way to specify some
> forced settings within the PHY's node for such cases?
>
> Only thing I found vaguely resembling what I'm looking for is Florian's
> patch introducing "max-speed" in the PHY -- not quite the same thing though.
> Which, if I understand it correctly, implements it as a property of the PHY,
> whereas ePAPR specifies it as a property of the ethernet device (which makes
> sense, since you might want to connect a 10/100 MII to a 10/100/1000 PHY and
> therefore have the MII restrict the capabilities of the PHY).

You shouldn't need a property in this case. The driver knows what the
h/w is limited to and can configure the phy based on that. It is when
both sides should support a higher speed and you need to limit it for
some other reason like errata or board level configuration.

> Or perhaps I'm missing some important bits here?

Does this patch help you:

https://lkml.org/lkml/2014/1/15/533

Rob

>
> Thanks!
> Gerlando
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
