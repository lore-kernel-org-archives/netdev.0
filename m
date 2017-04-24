From: Will Deacon <will.deacon@arm.com>
Subject: Re: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Mon, 24 Apr 2017 15:53:04 +0100
Message-ID: <20170424145304.GK12323@arm.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
 <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
 <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E205352FC@FRAEML521-MBX.china.huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E2053543C@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Ancel <amira@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dingtianhong <dingtianhong@huawei.com>,
        Linuxarm <linuxarm@huawei.com>
To: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:57768 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1172972AbdDXOxL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 10:53:11 -0400
Content-Disposition: inline
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E2053543C@FRAEML521-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 02:46:19PM +0000, Gabriele Paoloni wrote:
> > From: Amir Ancel [mailto:amira@mellanox.com]
> > Sent: 18 April 2017 21:18
> > To: David Laight; Gabriele Paoloni; davem@davemloft.net
> > Cc: Catalin Marinas; Will Deacon; Mark Rutland; Robin Murphy;
> > jeffrey.t.kirsher@intel.com; alexander.duyck@gmail.com; linux-arm-
> > kernel@lists.infradead.org; netdev@vger.kernel.org; Dingtianhong;
> > Linuxarm
> > Subject: Re: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
> > ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
> > 
> > Hi,
> > mlx5 driver is planned to have RO support this year.
> > I believe drivers should be able to query whether the arch support it
> 
> I guess that here when you say query you mean having a config symbol
> that is set accordingly to the host architecture, right?
> 
> As already said I have looked around a bit and other drivers do not seem
> to enable/disable RO for their EP on the basis of the host architecture.
> So why should mlx5 do it according to the host?
> 
> Also my understating is that some architectures (like ARM64 for example)
> can have different PCI host controller implementations depending on the
> vendor...therefore maybe it is not appropriate there to have a Kconfig
> symbol selected by the architecture...  

Indeed. We're not able to determine whether or not RO is supported at
compile time, so we'd have to detect this dynamically if we want to support
it for arm64 with a single kernel Image. That means either passing something
through firmware, having the PCI host controller opt-in or something coarse
like a command-line option.

Will
