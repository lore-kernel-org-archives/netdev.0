From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH 5/5] ixgbe: add driver set_max_vfs support
Date: Wed, 3 Oct 2012 19:16:23 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0715327581@ORSMSX106.amr.corp.intel.com>
References: <506C3B11.9010009@redhat.com>
 <1349286695-26713-1-git-send-email-yinghai@kernel.org>
 <1349286695-26713-6-git-send-email-yinghai@kernel.org>
 <506C8837.5070902@intel.com> <506C8BCB.4080402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"yuvalmin@broadcom.com" <yuvalmin@broadcom.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net--no-chain-reply-to"
	<davem@davemloft.net--no-chain-reply-to>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Don Dutile <ddutile@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <506C8BCB.4080402@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Don Dutile [mailto:ddutile@redhat.com]
> Sent: Wednesday, October 03, 2012 12:03 PM
> To: Duyck, Alexander H
> Cc: Yinghai Lu; Bjorn Helgaas; Greg Kroah-Hartman; linux-
> pci@vger.kernel.org; linux-kernel@vger.kernel.org; yuvalmin@broadcom.com;
> bhutchings@solarflare.com; Rose, Gregory V; davem@davemloft.net--no-chain-
> reply-to; Kirsher, Jeffrey T; Brandeburg, Jesse; David S. Miller;
> Fastabend, John R; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org
> Subject: Re: [PATCH 5/5] ixgbe: add driver set_max_vfs support
> 
> On 10/03/2012 02:47 PM, Alexander Duyck wrote:

[snip]

> >
> > The ixgbe_set_max_vfs function has several issues.  The two big ones
> > are that this function assumes it can just enable/disable SR-IOV
> > without any other changes being necessary which is not the case.  I
> > would recommend looking at ixgbe_setup_tc for how to do this properly.
> > Secondly is the fact that this code will change the PF network device
> > and as such sections of the code should be called with the RTNL lock
> > held.  In addition I believe you have to disable SR-IOV before
> > enabling it again with a different number of VFs.
> >
> > Below is a link to one of the early patches for igb when we were first
> > introducing SR-IOV, and the in-driver sysfs value had been rejected.
> > I figure it might be useful as it was also using sysfs to
> > enable/disable VFs.  It however doesn't have the correct locking on
> > changing the queues and as such will likely throw an error if you were
> > to implement it the same way now:
> > http://lists.openwall.net/netdev/2009/04/08/34
> >
> > Thanks,
> >
> > Alex
> 
> Alex,
> Thanks for patch set pointer.
> When I started to work on the ixgbe example use based on the RFC set I
> posted, I ran into the problem you outlined -- the PF uses/consumes all
> the queues & MSI intrs when sriov not enabled at driver load time, which
> required more network shutdown logic that I'm not familiar with... So, I
> was going to defer to Greg to work that magic. :)
> Greg: assume the 2 callback function interface in the RFC patch set I
> sent,
>        (primarily, just the include/linux/pci.h changes), and you can make
> the
>        necessary drivers mods from there.  In the meantime, I'll make the
> changes
>        to my original/v1 RFC to reflect the changes that GKH & Yinghai
> recommended/implemented
>        for sysfs attribute creation & removal in a v2 posting.
>        The end result is that the current module parameter setting for
> max_vfs should
>        continue to work, and the sysfs interface will work when those
> pieces are provided.

OK, I'll start work on it.

Thanks Don,

- Greg

> 
> -Don
