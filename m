From: Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH net-next V0 18/21] mlx4_core: adjust catas operation for
 SRIOV mode
Date: Sun, 4 Dec 2011 15:45:40 +0000
Message-ID: <D554B471892C914E90E136467281724D235C0A1C@MTLDAG01.mtl.com>
References: <4ED8A62D.8080008@mellanox.co.il>
 <CAL1RGDWp2fysTgVgSi30X+nf=66fArPRdXUXedbKxKjyHQqidQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDWp2fysTgVgSi30X+nf=66fArPRdXUXedbKxKjyHQqidQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Fri, Dec 2, 2011 at 2:19 AM, Yevgeny Petrilin
> <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> wrote:
> > When running in SRIOV mode, driver should not automatically
> start/stop
> > the mlx4_core upon sensing an HCA internal error -- doing this
> disables/enables
> > sriov, which will cause the hypervisor to hang if there are running
> VMs with
> > attached VFs.
> 
> Not sure I understand this -- what happens if the driver doesn't reset
> the device
> after a catastrophic error?  Surely all the VFs are pretty screwed at
> that point?
> 
> Which hypervisor are we talking about here anyway?
> 
>  - R.

Indeed, if you don't reset the device after an internal error, the PF/VF might not work properly unless you reload the PF driver.

However, invoking the SW reset by the PF (upon detecting an internal error) currently affects the SRIOV capability on the PCI so we cannot do it before disabling SRIOV first.
Since the driver is not in charge of passing-through VFs to VMs, it cannot disable SRIOV either so we cannot reset the device while using SRIOV.
Note that the single-function behavior is not modified.

We intend to post a fix for this in a different patch-set.
--Liran

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
