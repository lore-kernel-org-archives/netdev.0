From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: fix qed_fill_link() error handling
Date: Wed, 1 Jun 2016 11:10:30 +0000
Message-ID: <CO2PR11MB00885CC1028BFEAD9CD85E8397470@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
 <5288285.fZuaAytaxX@wuerfel>
 <CO2PR11MB0088EB31E72E7E898DE763A797470@CO2PR11MB0088.namprd11.prod.outlook.com>
 <8209894.K472MDjuEr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8209894.K472MDjuEr@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > I think we can just remove the IS_ENABLED() check there and define
> > > the
> > > IS_PF() macro conditionally to become 'true' if CONFIG_QED_SRIOV is
> > > not set, like some other drivers do
> >
> > I think that would be unsafe with current qede - qede currently
> > publishes its VFs' PCI device-id as part its MODULE_DEVICE_TABLE, even
> > if CONFIG_QED_SRIOV isn't enabled [might be the wrong thing to do, but
> > that how it goes].
> > Without changing this, if for some reason we'd have an assigned VF to
> > a VM whose kernel isn't compiled with CONFIG_QED_SRIOV [which is an
> > odd config], that VM is likely to miserably crash.
> 
> Wouldn't it crash anyway if the code to handle VF devices is not present?
> E.g. the warning we got here tells us that qed_get_link_data() operates on
> uninitialized data when called on a VF device and SRIOV support is not built into
> the driver. I haven't looked if all the other functions handle that right, but my
> guess is that there are other functions with similar problems.
> 
> Maybe it's best to remove the PCI IDs fort the virtual devices from the table if
> they are not supported by the configuration.

Actually, I think VF probe should gracefully fail in that case,
as qed_vf_hw_prepare() would simply return -EINVAL.
But I can honestly say I've never tested this flow, and I agree there's
no reason to allow VF probe in case we're not supporting SRIOV.

So I guess removing the PCI ID and defining IS_PF to be true in case
CONFIG_QED_SRIOV isn't set is the right way to go.
Do you want to revise your patch, or do you want me to do it?

Thanks,
Yuval
