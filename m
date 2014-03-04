From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv3 1/4] net: phy: decouple PHY id and PHY address in
 fixed PHY driver
Date: Tue, 4 Mar 2014 20:04:24 +0100
Message-ID: <20140304200424.66a6171f@skate>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1393930704-24374-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<CAGVrzcYF0g-vDpkP_fnqb13faPtOOSy_Pqfo-Pgti0S26-1nSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcYF0g-vDpkP_fnqb13faPtOOSy_Pqfo-Pgti0S26-1nSg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Florian Fainelli,

On Tue, 4 Mar 2014 10:43:12 -0800, Florian Fainelli wrote:

> >  struct fixed_phy {
> > -       int id;
> > +       int addr;
> >         u16 regs[MII_REGS_NUM];
> >         struct phy_device *phydev;
> >         struct fixed_phy_status status;
> > @@ -104,8 +104,8 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
> >         if (fp->status.asym_pause)
> >                 lpa |= LPA_PAUSE_ASYM;
> >
> > -       fp->regs[MII_PHYSID1] = fp->id >> 16;
> > -       fp->regs[MII_PHYSID2] = fp->id;
> > +       fp->regs[MII_PHYSID1] = 0xdead;
> > +       fp->regs[MII_PHYSID2] = 0xbeef;
> 
> I am still scratching my head as to whether we want that change to be
> in this particular version of changes, or if we want that to happen at
> a later time when (if?) we can finally get some proper OUI number
> allocation.
> 
> Technically we are presenting some sort of ABI to user-space, although
> detecting a fixed PHY device by reading its MII_PHYSID1/2 and matching
> it against its PHY address on the fixed MDIO bus would have been a
> little "weak" (especially when you can check that the parent device in
> sysfs is the fixed-0 bus).

Well the problem is that fp->id really isn't an id, it's the fake
address of the PHY on the fake fixed MDIO bus. So it would mean that
the MII_PHYSID of the first fixed PHY would probably be 0x0, then the
second would have 0x1, then 0x2, and so on.

Probably not worse than what is done today, though.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
