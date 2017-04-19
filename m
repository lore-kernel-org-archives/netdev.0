From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: RE: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Wed, 19 Apr 2017 14:46:19 +0000
Message-ID: <EE11001F9E5DDD47B7634E2F8A612F2E2053543C@FRAEML521-MBX.china.huawei.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
 <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>,<063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
 <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E205352FC@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dingtianhong <dingtianhong@huawei.com>,
        Linuxarm <linuxarm@huawei.com>
To: Amir Ancel <amira@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5780 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935388AbdDSOqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 10:46:48 -0400
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E205352FC@FRAEML521-MBX.china.huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amir
 
> From: Amir Ancel [mailto:amira@mellanox.com]
> Sent: 18 April 2017 21:18
> To: David Laight; Gabriele Paoloni; davem@davemloft.net
> Cc: Catalin Marinas; Will Deacon; Mark Rutland; Robin Murphy;
> jeffrey.t.kirsher@intel.com; alexander.duyck@gmail.com; linux-arm-
> kernel@lists.infradead.org; netdev@vger.kernel.org; Dingtianhong;
> Linuxarm
> Subject: Re: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
> ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
> 
> Hi,
> mlx5 driver is planned to have RO support this year.
> I believe drivers should be able to query whether the arch support it

I guess that here when you say query you mean having a config symbol
that is set accordingly to the host architecture, right?

As already said I have looked around a bit and other drivers do not seem
to enable/disable RO for their EP on the basis of the host architecture.
So why should mlx5 do it according to the host?

Also my understating is that some architectures (like ARM64 for example)
can have different PCI host controller implementations depending on the
vendor...therefore maybe it is not appropriate there to have a Kconfig
symbol selected by the architecture...  

Thanks
Gab

> or not and enable it in the network adapter accordingly.
> 
> -Amir
> ________________________________________
> From: netdev-owner@vger.kernel.org <netdev-owner@vger.kernel.org> on
> behalf of David Laight <David.Laight@ACULAB.COM>
> Sent: Tuesday, April 18, 2017 4:25:44 PM
> To: 'Gabriele Paoloni'; davem@davemloft.net
> Cc: Catalin Marinas; Will Deacon; Mark Rutland; Robin Murphy;
> jeffrey.t.kirsher@intel.com; alexander.duyck@gmail.com; linux-arm-
> kernel@lists.infradead.org; netdev@vger.kernel.org; Dingtianhong;
> Linuxarm
> Subject: RE: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
> ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
> 
> From: Gabriele Paoloni
> > Sent: 13 April 2017 10:11
> > > > Till now only the Intel ixgbe could support enable
> > > > Relaxed ordering in the drivers for special architecture,
> > > > but the ARCH_WANT_RELAX_ORDER is looks like a general name
> > > > for all arch, so rename to a specific name for intel
> > > > card looks more appropriate.
> > > >
> > > > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> > >
> > > This is not a driver specific facility.
> > >
> > > Any driver can test this symbol and act accordingly.
> > >
> > > Just because IXGBE is the first and only user, doesn't mean
> > > the facility is driver specific.
> >
> >
> > Please correct me if I am wrong but my understanding is that the
> standard
> > way to enable/disable relaxed ordering is to set/clear bit 4 of the
> Device
> > Control Register (PCI_EXP_DEVCTL_RELAX_EN 0x0010 /* Enable relaxed
> > ordering */).
> > Now I have looked up for all drivers either enabling or disabling
> relaxed
> > ordering and none of them seems to need a symbol to decide whether to
> > enable it or not.
> > Also it seems to me enabling/disabling relaxed ordering is never
> bound to the
> > host architecture.
> >
> > So why this should be (or it is expected to be) a generic symbol?
> > Wouldn't it be more correct to have this as a driver specific symbol
> now and
> > move it to a generic one later once we have other drivers requiring
> it?
> 
> 'Relaxed ordering' is a bit in the TLP header.
> A device (like the ixgbe hardware) can set it for some transactions and
> still have the transactions 'ordered enough' for the driver to work.
> (If all transactions have 'relaxed ordering' set then I suspect it is
> almost impossible to write a working driver.)
> The host side could (probably does) have a bit to enable 'relaxed
> ordering',
> it could also enforce stronger ordering than required by the PCIe spec
> (eg keeping reads in order).
> 
> Clearly, on some sparc64 systems, ixgbe needs to use 'relaxed
> ordering'.
> To me this requires two separate bits be enabled:
> 1) to the ixgbe driver to generate the 'relaxed' TLP.
> 2) to the host to actually act on them.
> If the ixgbe driver works when both are enabled why have options to
> disable either (except for bug-finding)?
> 
>         David
