From: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the
 DP83867 TI's PHY driver
Date: Wed, 1 Feb 2017 22:05:00 +0100
Message-ID: <20170201220500.29d478aa@jawa>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
        <20170201171610.GC7395@lunn.ch>
        <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Karicheri Muralidharan <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2f3766f0-42df-6aab-dda1-14022c57fb30-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear All,

Thanks for prompt reply.

> On 02/01/2017 09:16 AM, Andrew Lunn wrote:
> > On Wed, Feb 01, 2017 at 03:43:35PM +0100, Lukasz Majewski wrote:
> >> This patch adds support for enabling or disabling the port
> >> mirroring feature of the DP83867 TI's PHY device.
> >>
> >> One use case is when bootstrap configuration enables this feature
> >> (because of e.g. LED wiring) so then one needs to disable it in
> >> software (u-boot/Linux).
> > 
> > Hi Lukasz
> > 
> > How does this differ from "enet-phy-lane-swap"?
> 
> Same here, I am confused about what port mirroring could be meaning
> here

The "net-phy-lane-swap" when defined indicates that the "lane swap"
needs to be enabled. This is a simple bool variable. In my case it
would mean: "please enable port mirroring -> write 1 to CFG4 register's
PORT_MIRROR_EN field"

My use case is unfortunately different:

- Due to HW design - during the bootstrap PHY phase - the PHY enables
  "port mirroring", which is incorrect. 

Then, in SW I do need to explicitly disable port mirroring (write 0 to
PORT_MIRROR_EN field in CFG4 register). 


> and if we can find a better way to describe what is being added.
> Thanks!

We would need a tri-state device tree properly:

1. Not defined - do nothing
2. Defined as 0 -> explicitly disable port mirroring
3. Defined as 1 -> explicitly enable port mirriring

The "net-phy-lane-swap" only fulfills points 1 and 3 above.

In my use case I do need point 2.

Best regards,

Lukasz Majewski

--

DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd-ynQEQJNshbs@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
