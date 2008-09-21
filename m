From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Sun, 21 Sep 2008 23:00:50 +0400
Message-ID: <20080921190050.GA20484@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921113513.16677c4e-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 21, 2008 at 11:35:13AM -0700, Arjan van de Ven (arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org) wrote:
> > And how else user can get attention to the problem which is not fixed
> > by the vendor? 
> 
> ... or the community

Which does not have access to the firmware... Which IMO is failing and
not the driver itself.

> > It stops after several seconds (or packets?). Sometimes (but rarely)
> > it works several minutes, sometimes it fires above dmesg line and
> > continues to work, sometimes it fires it for a while and then stops
> > writing it, although driver does not send or receive anything (at
> > least ifconfig counters do not change).
> 
> again.. so how about you detect this condition and do, in the driver
> code, the equivalent of rmmod/insmod to the hardware. I'm sure people
> who have the hardware would appreciate that type of patch a lot more
> than the one you sent out.
 
Reset task does efectively ipw2100_up(), so the difference is power
cycles over the PCI bus and enable/disable/request commands. Like this
stuff:
	/* We disable the RETRY_TIMEOUT register (0x41) to keep
	 * PCI Tx retries from interfering with C3 CPU state */
	pci_read_config_dword(pci_dev, 0x40, &val);
	if ((val & 0x0000ff00) != 0)
		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);

I do remember I had a tibet monk course of decoding ipw2100 PCI
config address space, just need to find my kimono.

Do you want me to implement ipw2100 driver as a big work structure
which will run ipw2100_init()/wait/ipw2100_exit() in a loop?
And that will be the fix suggested by Intel? That would explain a lot.

P.S. And some people tell that asking for bug bisection is a hard
pressure on user. Vendor has to ask him to fix bug himself instead,
and that will be a solution!

Getting the fact, that rmmod/insmod does not always fix the problem (but
most of the time for a short period of time), I again want to point,
that it looks like a firmware problem related to some inner timings. You
ask me to fix the driver and do not even listen to what I said
previously and do not get that into account and analyze.

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
