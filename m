From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Fri, 28 Apr 2017 10:51:11 +0200
Message-ID: <1493369471.13947.11.camel@pengutronix.de>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
         <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
         <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
         <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
         <a2239141-a185-1bb8-0abd-7a05b9fde015@huawei.com>
         <CAKgT0Uc4L=GgYbpO-Fm9OfN+_fLypbDP1c+X4T_ta90ecQiyGQ@mail.gmail.com>
         <20170427171938.GA10705@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Robin Murphy <robin.murphy@arm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Casey Leedom <leedom@chelsio.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170427171938.GA10705@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, den 27.04.2017, 12:19 -0500 schrieb Bjorn Helgaas:
> [+cc Casey]
> 
> On Wed, Apr 26, 2017 at 09:18:33AM -0700, Alexander Duyck wrote:
> > On Wed, Apr 26, 2017 at 2:26 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> > > Hi Amir:
> > >
> > > It is really glad to hear that the mlx5 will support RO mode this year, if so, do you agree that enable it dynamic by ethtool -s xxx,
> > > we have try it several month ago but there was only one drivers would use it at that time so the maintainer against it, it mlx5 would support RO,
> > > we could try to restart this solution, what do you think about it. :)
> > >
> > > Thanks
> > > Ding
> > 
> > Hi Ding,
> > 
> > Enabing relaxed ordering really doesn't have any place in ethtool. It
> > is a PCIe attribute that you are essentially wanting to enable.
> > 
> > It might be worth while to take a look at updating the PCIe code path
> > to handle this. Really what we should probably do is guarantee that
> > the architectures that need relaxed ordering are setting it in the
> > PCIe Device Control register and that the ones that don't are clearing
> > the bit. It's possible that this is already occurring, but I don't
> > know the state of handling those bits is in the kernel. Once we can
> > guarantee that we could use that to have the drivers determine their
> > behavior in regards to relaxed ordering. For example in the case of
> > igb/ixgbe we could probably change the behavior so that it will bey
> > default try to use relaxed ordering but if it is not enabled in PCIe
> > Device Control register the hardware should not request to use it. It
> > would simplify things in the drivers and allow for each architecture
> > to control things as needed in their PCIe code.
> 
> I thought Relaxed Ordering was an optimization.  Are there cases where
> it is actually required for correct behavior?

Yes, at least the Tegra 2 TRM claims that RO needs to be enabled on the
device side for correct operation with the following language:

"Tegra 2 requires relaxed ordering for responses to downstream requests
(responses can pass writes). It is possible in some circumstances for
PCIe transfers from an external bus masters (i.e. upstream transfers) to
become blocked by a downstream read or non-posted write. The responses
to these downstream requests are blocked by upstream posted writes only
when PCIe strict ordering is imposed. It is therefore necessary to never
impose strict ordering that would block a response to a downstream
NPW/read request and always set the relaxed ordering bit to 1. Only
devices that are capable of relaxed ordering may be used with Tegra 2
devices."

Regards,
Lucas
